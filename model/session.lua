Session = mondelefant.new_class()
Session.table = 'session'
Session.primary_key = { 'ident' } 

Session:add_reference{
  mode          = 'm1',
  to            = "Member",
  this_key      = 'member_id',
  that_key      = 'id',
  ref           = 'member',
}

local function random_string()
  return multirand.string(
    32,
    '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
  )
end

-- Login sessions (README, "Login sessions"): an anonymous session is
-- created on the first request without a valid cookie and lasts 24 hours
-- from then (the column default of "expiry"). A login creates a new session
-- (new ident and CSRF secret; the anonymous one is deleted), which expires
-- config.session_idle_lifetime after the last renewal, at most
-- config.session_max_lifetime after the login ("logged_in_at"). The expiry
-- is renewed at most once per config.session_renew_interval. Sessions
-- without "logged_in_at" (anonymous ones, and logged in ones created
-- before this code) are never extended.

local cookie_name = "liquid_feedback_session"

-- Sends the session cookie: with Max-Age (seconds) for a logged in
-- session, without (ends with the browser) for an anonymous one.
function Session.object:send_cookie(max_age)
  request.set_cookie{
    name      = cookie_name,
    value     = self.ident,
    max_age   = max_age and math.max(0, math.floor(tonumber(max_age))),
    http_only = true,
    same_site = "Lax"
  }
end

-- A new anonymous session (saved; no cookie sent).
function Session:new()
  local session = self.prototype.new(self)  -- super call
  session.ident             = random_string()
  session.additional_secret = random_string()
  session:save() 
  return session
end

-- The unexpired session with the ident, or nil. Field "renew_due": the
-- expiry of a logged in session is more than the renew interval behind
-- its target (Session.object:renew()).
function Session:by_ident(ident)
  local selector = self:new_selector()
  selector:add_where{ '"session"."ident" = ?', ident }
  selector:add_where('"session"."expiry" > now()')
  selector:add_field{
    'coalesce("session"."member_id" IS NOT NULL AND "session"."logged_in_at" IS NOT NULL'
    .. ' AND "session"."expiry" < LEAST(now() + ?::interval, "session"."logged_in_at" + ?::interval) - ?::interval,'
    .. ' FALSE) AS "renew_due"',
    config.session_idle_lifetime,
    config.session_max_lifetime,
    config.session_renew_interval
  }
  selector:optional_object_mode()
  return selector:exec()
end

-- Logs the member in on a new session (call inside the action's
-- transaction, then redirect, so that the next request uses the new CSRF
-- secret): the current session (app.session) is deleted, its language is
-- kept, and the new one becomes app.session; its cookie is sent with
-- Max-Age. Returns nil (nothing changed) if the member is locked: the
-- member row is read FOR SHARE, so a lock running at the same time either
-- came first (no session) or waits for this transaction and then deletes
-- the new session (core's trigger). With password_hash (login), also nil
-- if the member's password hash is no longer that one (the password was
-- changed or reset after it was checked).
function Session:login(member, password_hash)
  local old = app.session
  local ident = random_string()
  local password_check = password_hash and { ' AND "password" = ?', password_hash } or ""
  local result = db:query({
    'INSERT INTO "session" ("ident", "additional_secret", "member_id", "lang", "logged_in_at", "expiry")'
    .. ' SELECT ?, ?, "id", ?, now(), LEAST(now() + ?::interval, now() + ?::interval)'
    .. ' FROM "member" WHERE "id" = ? AND NOT "locked"$ FOR SHARE'
    .. ' RETURNING floor(extract(epoch FROM "expiry" - now()))::int8 AS "max_age"',
    ident,
    random_string(),
    old and old.lang or nil,
    config.session_idle_lifetime,
    config.session_max_lifetime,
    member.id,
    { password_check }
  }, "opt_object")
  if not result then
    return nil
  end
  if old then
    db:query{ 'DELETE FROM "session" WHERE "ident" = ?', old.ident }
  end
  app.session = Session:by_ident(ident)
  app.session:send_cookie(result.max_age)
  return app.session
end

-- Extends the expiry of a logged in session to its target (idle lifetime
-- from now, capped at the maximum lifetime after the login) and sends the
-- cookie with the new Max-Age.
function Session.object:renew()
  local result = db:query({
    'UPDATE "session" SET "expiry" = LEAST(now() + ?::interval, "logged_in_at" + ?::interval)'
    .. ' WHERE "ident" = ? AND "member_id" IS NOT NULL AND "logged_in_at" IS NOT NULL'
    .. ' RETURNING floor(extract(epoch FROM "expiry" - now()))::int8 AS "max_age"',
    config.session_idle_lifetime,
    config.session_max_lifetime,
    self.ident
  }, "opt_object")
  -- (self.renew_due is not changed: a field set on the object would be
  -- saved as a column by a later save() in this request.)
  if result then
    self:send_cookie(result.max_age)
  end
end

-- Ends the current session (deleted) and starts a new anonymous one with
-- the same language; its cookie (without Max-Age) replaces the old one.
function Session:logout()
  local lang = app.session and app.session.lang
  if app.session then
    db:query{ 'DELETE FROM "session" WHERE "ident" = ?', app.session.ident }
  end
  app.session = Session:new()
  if lang then
    app.session.lang = lang
    app.session:save()
  end
  app.session:send_cookie()
  return app.session
end

-- Deletes all sessions of the member, except the one with except_ident.
function Session:delete_for_member(member_id, except_ident)
  if except_ident then
    db:query{ 'DELETE FROM "session" WHERE "member_id" = ? AND "ident" <> ?', member_id, except_ident }
  else
    db:query{ 'DELETE FROM "session" WHERE "member_id" = ?', member_id }
  end
end

function Session.object:has_access(level)
  if level == "member" then
    if app.session.member_id then
      return true
    else
      return false
    end
  
  elseif level == "everything" then
    if self:has_access("member") or config.public_access == "everything" then
      return true
    else
      return false
    end

  elseif level == "all_pseudonymous" then
    if self:has_access("everything") or config.public_access == "all_pseudonymous" then
      return true
    else
      return false
    end

  elseif level == "authors_pseudonymous" then
    if self:has_access("all_pseudonymous") or config.public_access == "authors_pseudonymous" then
      return true
    else
      return false
    end

  elseif level == "anonymous" then
    if self:has_access("authors_pseudonymous") or config.public_access == "anonymous" then
      return true
    else
      return false
    end
    
  end
  
  error("invalid access level")
end
