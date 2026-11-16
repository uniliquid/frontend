# Test only, run by tests/run.sh inside the test image (tests/in-container.sh):
# the login session handling end to end. Each request runs WebMCP's CGI
# script with the frontend in /app against the database liquid_feedback
# (core.sql and session.sql). Synthetic data only.

import html.parser
import os
import re
import subprocess
import sys
import urllib.parse

BASE = "https://lf.example.org/"
COOKIE = "liquid_feedback_session"
failures = 0


def check(name, condition, detail=""):
    global failures
    print(("ok   " if condition else "FAIL ") + name)
    if not condition:
        failures += 1
        if detail:
            print("     " + str(detail))


def sql(query):
    """Runs the query; the rows as lists of strings."""
    out = subprocess.run(["psql", "-X", "-q", "-A", "-t", "-F", "|", "-v", "ON_ERROR_STOP=1",
                          "-d", "liquid_feedback", "-c", query],
                         check=True, capture_output=True, text=True).stdout
    return [line.split("|") for line in out.splitlines() if line != ""]


def value(query):
    rows = sql(query)
    return rows[0][0] if rows else None


class Response:
    def __init__(self, raw):
        head, _, self.body = raw.partition("\r\n\r\n")
        self.headers = head.split("\r\n")
        status = [h for h in self.headers if h.startswith("Status: ")]
        self.status = status[0][8:11] if status else "200"
        self.cookies = [h[len("Set-Cookie: "):] for h in self.headers if h.startswith("Set-Cookie: " + COOKIE + "=")]

    def cookie(self):
        """The last session cookie sent: (ident, attributes), or None."""
        if not self.cookies:
            return None
        parts = self.cookies[-1].split("; ")
        return parts[0].split("=", 1)[1], parts[1:]

    def max_age(self):
        for attribute in self.cookie()[1]:
            if attribute.startswith("Max-Age="):
                return int(attribute[8:])
        return None


def request(path, ident=None, data=None, config_name="test"):
    """A request as the web server's rewrite rules pass it to the CGI
    script; path like "/", "/module/view.html" or "/module/action"."""
    path, _, query = path.partition("?")
    parts = path.strip("/").split("/") if path != "/" else []
    if not parts:
        params = {"_webmcp_urldepth": "0", "_webmcp_module": "index", "_webmcp_view": "index"}
    elif len(parts) == 2 and "." not in parts[1]:
        params = {"_webmcp_urldepth": "1", "_webmcp_module": parts[0], "_webmcp_action": parts[1]}
    elif len(parts) == 2:
        view, suffix = parts[1].split(".")
        params = {"_webmcp_urldepth": "1", "_webmcp_module": parts[0], "_webmcp_view": view, "_webmcp_suffix": suffix}
    else:
        view_id, suffix = parts[2].split(".")
        params = {"_webmcp_urldepth": "2", "_webmcp_module": parts[0], "_webmcp_view": parts[1],
                  "_webmcp_id": view_id, "_webmcp_suffix": suffix}
    query_string = urllib.parse.urlencode(params) + ("&" + query if query else "")
    body = urllib.parse.urlencode(data or {}).encode()
    env = {"PATH": os.environ["PATH"], "LANG": "C.UTF-8", "HTTPS": "on",
           "REQUEST_METHOD": "POST" if data is not None else "GET", "QUERY_STRING": query_string,
           "WEBMCP_APP_BASEPATH": "/app/", "WEBMCP_CONFIG_NAME": config_name}
    if ident:
        env["HTTP_COOKIE"] = COOKIE + "=" + ident
    if data is not None:
        env["CONTENT_TYPE"] = "application/x-www-form-urlencoded"
        env["CONTENT_LENGTH"] = str(len(body))
    result = subprocess.run(["lua5.1", "webmcp-wrapper.lua"], cwd="/opt/webmcp/cgi-bin", env=env,
                            input=body, capture_output=True)
    return Response(result.stdout.decode("utf-8", "replace"))


class Forms(html.parser.HTMLParser):
    """The forms of a page: [(action path, {name: value})]."""

    def __init__(self, page):
        super().__init__()
        self.forms = []
        self.feed(page)

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == "form":
            action = attrs.get("action") or ""
            self.forms.append((urllib.parse.urlparse(action).path, {}))
        elif tag == "input" and self.forms and attrs.get("name") and attrs.get("type") != "submit":
            if attrs.get("type") in ("checkbox", "radio") and "checked" not in attrs:
                return
            self.forms[-1][1][attrs["name"]] = attrs.get("value") or ""
        elif tag in ("textarea", "select") and self.forms and attrs.get("name"):
            self.forms[-1][1].setdefault(attrs["name"], "")


def row(ident):
    """The session row: dict, or None."""
    rows = sql(f"""SELECT member_id, logged_in_at IS NOT NULL, extract(epoch FROM expiry - now())::int,
        additional_secret, lang FROM session WHERE ident = '{ident}'""")
    if not rows:
        return None
    member_id, logged_in, expiry, secret, lang = rows[0]
    return {"member_id": int(member_id) if member_id else None, "logged_in_at": logged_in == "t",
            "expiry": int(expiry), "secret": secret, "lang": lang or None}


def anonymous():
    """A new anonymous session: its ident."""
    response = request("/")
    return response.cookie()[0]


def action(path, ident, fields, secret=None, mode="redirect"):
    """POSTs an action from the session ident (with its CSRF secret) with
    routing (redirect or forward) to the start page."""
    data = {"_webmcp_csrf_secret": secret or row(ident)["secret"], "_webmcp_routing.default.mode": mode,
            "_webmcp_routing.default.module": "index", "_webmcp_routing.default.view": "index"}
    data.update(fields)
    return request(path, ident, data)


def submit(page_path, action_path, ident, fields):
    """Submits the form for action_path on the page page_path (its fields
    as rendered, with the given ones changed; None removes a field)."""
    page = request(page_path, ident)
    forms = [f for f in Forms(page.body).forms if f[0].endswith(action_path)]
    assert forms, "form for " + action_path + " found on " + page_path
    data = dict(forms[0][1])
    for name, field in fields.items():
        if field is None:
            data.pop(name, None)
        else:
            data[name] = field
    return request(action_path, ident, data)


def login(login_name, password, ident=None, mode=None):
    """Logs in with the login form (its routing, or the given mode); the
    response and the new ident."""
    ident = ident or anonymous()
    page = request("/index/login.html", ident)
    forms = [f for f in Forms(page.body).forms if f[0].endswith("/index/login")]
    assert forms, "login form found"
    data = dict(forms[0][1], login=login_name, password=password)
    if mode:
        data.update({"_webmcp_routing.default.mode": mode, "_webmcp_routing.default.module": "index",
                     "_webmcp_routing.default.view": "index"})
    response = request("/index/login", ident, data)
    cookie = response.cookie()
    return response, cookie[0] if cookie else None


DAY = 86400
# --- Members (synthetic) -----------------------------------------------------

def member(login_name, password, admin=False):
    member_id = value(f"""INSERT INTO member (login, password, name, activated, active, admin, last_activity)
        VALUES ('{login_name}', crypt('{password}', gen_salt('md5')), '{login_name}', now(), TRUE,
        {'TRUE' if admin else 'FALSE'}, now()) RETURNING id""")
    sql(f"""INSERT INTO setting (member_id, key, value) VALUES
        ({member_id}, 'use_terms_checkbox_terms_of_use_v1', 'accepted'),
        ({member_id}, 'use_terms_checkbox_extra_terms_of_use_v1', 'accepted')""")
    return int(member_id)


m1 = member("test-member-1", "test-password-1")
m2 = member("test-member-2", "test-password-2")
m3 = member("test-member-3", "test-password-3")
admin = member("test-admin-1", "test-password-admin", admin=True)

# --- A: anonymous session ----------------------------------------------------

response = request("/")
cookie = response.cookie()
check("A: a request without a cookie gets a session cookie", response.status == "200" and cookie is not None, response.headers)
a = cookie[0]
check("A: cookie path=/, secure, HttpOnly, SameSite=Lax, no Max-Age",
      cookie[1] == ["path=/", "secure", "HttpOnly", "SameSite=Lax"], cookie)
r = row(a)
check("A: anonymous row, no logged_in_at, expiry about 24 h",
      r and r["member_id"] is None and not r["logged_in_at"] and DAY - 120 < r["expiry"] <= DAY, r)
response = request("/", a)
check("A: the next request with the cookie: no new cookie", response.status == "200" and response.cookie() is None, response.headers)

# --- B: login creates a new session (fixation) --------------------------------

sql(f"INSERT INTO session (ident, additional_secret, member_id, logged_in_at) VALUES ('other-device-1', 'x', {m1}, now())")
sql(f"UPDATE session SET lang = 'de' WHERE ident = '{a}'")
old_secret = row(a)["secret"]
response, b = login("test-member-1", "test-password-1", a)
check("B: login redirects", response.status == "303", response.headers)
check("B: login sends a new ident", b is not None and b != a)
check("B: cookie path=/, secure, Max-Age 30 days, HttpOnly, SameSite=Lax",
      response.cookie() and response.cookie()[1][:2] == ["path=/", "secure"]
      and response.cookie()[1][3:] == ["HttpOnly", "SameSite=Lax"]
      and 30 * DAY - 120 < response.max_age() <= 30 * DAY, response.cookies)
check("B: the anonymous row is gone", row(a) is None)
r = row(b)
check("B: new row: the member, logged_in_at, expiry about 30 days, new CSRF secret",
      r and r["member_id"] == m1 and r["logged_in_at"] and 30 * DAY - 120 < r["expiry"] <= 30 * DAY
      and r["secret"] != old_secret, r)
check("L: the language chosen before the login is kept", r and r["lang"] == "de", r)
check("B: password rehash at login keeps the member's other sessions", row("other-device-1") is not None
      and value(f"SELECT password LIKE '$6$%' FROM member WHERE id = {m1}") == "t")

# --- C: the old ident is useless ----------------------------------------------

response = request("/", a)
check("C: replaying the pre-login cookie gives a new anonymous session",
      response.cookie() is not None and response.cookie()[0] != a and row(response.cookie()[0])["member_id"] is None)

# --- D: renewal -----------------------------------------------------------------

before = row(b)["expiry"]
response = request("/", b)
check("D: a request within the renew interval: no cookie, expiry unchanged",
      response.status == "200" and response.cookie() is None and abs(row(b)["expiry"] - before) <= 5, response.headers)
sql(f"UPDATE session SET expiry = now() + '14 days' WHERE ident = '{b}'")
response = request("/", b)
check("D: expiry 14 days ahead -> renewed to 30 days, cookie with the new Max-Age",
      response.cookie() and response.cookie()[0] == b and 30 * DAY - 120 < response.max_age() <= 30 * DAY
      and 30 * DAY - 120 < row(b)["expiry"] <= 30 * DAY, response.cookies)
sql(f"UPDATE session SET expiry = now() + '30 days' - '50 minutes'::interval WHERE ident = '{b}'")
response = request("/", b)
check("D: expiry less than the renew interval behind: not renewed", response.cookie() is None
      and row(b)["expiry"] < 30 * DAY - 2900)

# --- E: hard cap, expiry on lookup, sessions from before ------------------------

sql(f"UPDATE session SET logged_in_at = now() - '89 days'::interval, expiry = now() + '1 hour'::interval WHERE ident = '{b}'")
response = request("/", b)
check("E: renewal is capped at 90 days after the login (Max-Age about 1 day)",
      response.cookie() and DAY - 120 < response.max_age() <= DAY and DAY - 120 < row(b)["expiry"] <= DAY, response.cookies)
sql(f"UPDATE session SET expiry = now() - '1 second'::interval WHERE ident = '{b}'")
response = request("/", b)
check("E: an expired session is not used (before lf_update deletes it)",
      response.cookie() and response.cookie()[0] != b and row(response.cookie()[0])["member_id"] is None)
sql(f"INSERT INTO session (ident, additional_secret, member_id, expiry) VALUES ('legacy-1', 'x', {m1}, now() + '1 hour')")
response = request("/", "legacy-1")
check("E: a logged in session from before (no logged_in_at) is used but not extended",
      response.status == "200" and response.cookie() is None and row("legacy-1")["expiry"] <= 3600
      and row("legacy-1")["member_id"] == m1)

# --- K: CSRF secret of the old session ------------------------------------------

anon = anonymous()
anon_secret = row(anon)["secret"]
response, k = login("test-member-1", "test-password-1", anon)
response = action("/index/logout", k, {}, secret=anon_secret)
check("K: a form of the session before the login is refused after it (CSRF)",
      response.status != "303" and row(k) is not None and row(k)["member_id"] == m1, response.status)

# --- F: logout ------------------------------------------------------------------

response = action("/index/logout", k, {})
cookie = response.cookie()
check("F: logout redirects with a new anonymous cookie without Max-Age",
      response.status == "303" and cookie and cookie[0] != k and "Max-Age" not in " ".join(cookie[1])
      and cookie[1] == ["path=/", "secure", "HttpOnly", "SameSite=Lax"], response.headers)
check("F: the logged in row is deleted, the new one is anonymous",
      row(k) is None and row(cookie[0])["member_id"] is None)
response = request("/", k)
check("F: the logged out cookie gives a new anonymous session",
      response.cookie() and response.cookie()[0] != k)

# --- G: password change ---------------------------------------------------------

response, g1 = login("test-member-2", "test-password-2")
response, g2 = login("test-member-2", "test-password-2")
response = action("/member/update_password", g1, {"old_password": "test-password-2",
                  "new_password1": "test-password-2b", "new_password2": "test-password-2b"})
cookie = response.cookie()
check("G: password change redirects with a new logged in cookie",
      response.status == "303" and cookie and cookie[0] not in (g1, g2) and response.max_age() > 29 * DAY, response.headers)
check("G: the current device stays logged in on the new session, the old ident is gone",
      cookie and row(cookie[0])["member_id"] == m2 and row(cookie[0])["logged_in_at"] and row(g1) is None)
check("G: the other device is logged out", row(g2) is None)
g3 = cookie[0] if cookie else None
response = action("/member/update_password", g3, {"old_password": "wrong-password",
                  "new_password1": "test-password-2c", "new_password2": "test-password-2c"})
check("G: a refused password change keeps the session", row(g3) is not None)

# --- H: password reset ----------------------------------------------------------

response, h2 = login("test-member-2", "test-password-2b")
sql(f"""UPDATE member SET password_reset_secret = 'test-reset-secret-1', password_reset_secret_expiry = now() + '1 day'
    WHERE id = {m2}""")
h = anonymous()
response = action("/index/reset_password", h, {"secret": "test-reset-secret-1",
                  "password1": "test-password-2d", "password2": "test-password-2d"})
check("H: password reset succeeds", response.status == "303"
      and value(f"SELECT password_reset_secret IS NULL FROM member WHERE id = {m2}") == "t", response.status)
check("H: all sessions of the member are gone", value(f"SELECT count(*) FROM session WHERE member_id = {m2}") == "0")
check("H: the anonymous session doing the reset is kept", row(h) is not None)

# --- I: lock and deactivate -----------------------------------------------------

response, i1 = login("test-member-3", "test-password-3")
sql(f"UPDATE member SET locked = TRUE WHERE id = {m3}")
check("I: lock by SQL deletes the sessions (trigger)", row(i1) is None)
sql(f"UPDATE member SET locked = FALSE WHERE id = {m3}")
response, adm = login("test-admin-1", "test-password-admin")
response, i2 = login("test-member-3", "test-password-3")
response = submit(f"/admin/member_edit/{m3}.html", "/admin/member_update", adm, {"locked": "1"})
check("I: lock in the admin UI deletes the sessions", response.status == "303" and row(i2) is None
      and value(f"SELECT locked FROM member WHERE id = {m3}") == "t", response.status)
check("I: the admin stays logged in", row(adm) is not None and row(adm)["member_id"] == admin)
response, i3 = login("test-member-1", "test-password-1")
response = submit(f"/admin/member_edit/{m1}.html", "/admin/member_update", adm, {"deactivate": "1"})
check("I: deactivate in the admin UI deletes the sessions", response.status == "303" and row(i3) is None
      and value(f"SELECT password IS NULL FROM member WHERE id = {m1}") == "t", response.status)

# --- Renewal and a save of the session in the same request -------------------

response, s = login("test-member-2", "test-password-2d")
sql(f"UPDATE session SET expiry = now() + '14 days' WHERE ident = '{s}'")
response = action("/index/set_lang", s, {"lang": "de"})
check("renewal, then the action saves the session (set_lang) in the same request",
      response.status == "303" and row(s)["lang"] == "de" and row(s)["expiry"] > 30 * DAY - 120, (response.status, row(s)))

# --- Registration (invite code) ------------------------------------------------

m5 = int(value("""INSERT INTO member (invite_code, notify_email) VALUES ('test-invite-code-1', 'test-member-5@example.org')
    RETURNING id"""))
j = anonymous()
response = action("/index/register", j, {"step": "3", "code": "test-invite-code-1",
                  "notify_email": "test-member-5@example.org", "name": "test-member-5", "login": "test-member-5",
                  "password1": "test-password-5", "password2": "test-password-5"})
cookie = response.cookie()
check("J: registration logs in on a new session with Max-Age",
      response.status == "303" and cookie and cookie[0] != j and response.max_age() > 29 * DAY, response.headers)
check("J: the anonymous session is gone, the new one belongs to the new member",
      row(j) is None and cookie and row(cookie[0])["member_id"] == m5 and row(cookie[0])["logged_in_at"])

# --- Forwarded view after login and logout -------------------------------------

response, fw = login("test-member-2", "test-password-2d", mode="forward")
check("forward: login answers with the start page, logged in, new cookie",
      response.status == "200" and fw and row(fw) and row(fw)["member_id"] == m2
      and "/index/logout" in response.body and "system error" not in response.body, response.headers)
response = request("/", fw)
check("forward: the next request uses the new session", response.status == "200" and response.cookie() is None
      and "/index/logout" in response.body)
response = action("/index/logout", fw, {}, mode="forward")
cookie = response.cookie()
check("forward: logout answers with the start page and a new anonymous cookie",
      response.status == "200" and cookie and cookie[0] != fw and row(fw) is None
      and "Max-Age" not in " ".join(cookie[1]) and "system error" not in response.body, response.headers)

# --- Login of a member locked at the same time ---------------------------------

# Simulated: a lock committed between the password check and
# Session:login (a test-only trigger locks the member when the login
# action saves it).
m6 = member("test-member-6", "test-password-6")
sql(f"""CREATE FUNCTION test_lock_on_login() RETURNS trigger LANGUAGE plpgsql AS $$
    BEGIN NEW.locked := TRUE; RETURN NEW; END; $$;
    CREATE TRIGGER test_lock_on_login BEFORE UPDATE ON member FOR EACH ROW
    WHEN (OLD.id = {m6} AND NOT OLD.locked) EXECUTE PROCEDURE test_lock_on_login()""")
response, race = login("test-member-6", "test-password-6")
check("locked during the login: no session for the member, error shown",
      value(f"SELECT count(*) FROM session WHERE member_id = {m6}") == "0"
      and (race is None or row(race) is None or row(race)["member_id"] is None), response.headers)
sql("DROP TRIGGER test_lock_on_login ON member; DROP FUNCTION test_lock_on_login()")

# --- Configuration errors --------------------------------------------------------

test_config = open("/app/config/test.lua").read()
for name, setting in [("bad_format", 'config.session_idle_lifetime = "2 weeks"'),
                      ("bad_order", 'config.session_renew_interval = "30 days"'),
                      ("bad_max", 'config.session_max_lifetime = "29 days"')]:
    with open(f"/app/config/{name}.lua", "w") as f:
        f.write(setting + "\n" + test_config)
    response = request("/", config_name=name)
    check(f"config: {name} -> clear error message",
          "Invalid configuration: " in response.body and "config.session_" in response.body, response.body[:300])
with open("/app/config/without_session.lua", "w") as f:
    f.write(test_config.replace("dbname = 'liquid_feedback'", "dbname = 'lf_without_session'"))
subprocess.run(["psql", "-X", "-q", "-d", "lf_without_session", "-c",
                "INSERT INTO session (ident, additional_secret) VALUES ('test-ident-1', 'x')"], check=True)
response = request("/", "test-ident-1", config_name="without_session")
check("database without session.sql: a visitor with a cookie gets the error page naming the missing column",
      "logged_in_at" in response.body and "does not exist" in response.body, response.body[:300])

print("all passed" if failures == 0 else f"{failures} failed")
sys.exit(0 if failures == 0 else 1)
