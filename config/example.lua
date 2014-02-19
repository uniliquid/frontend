-- ========================================================================
-- MANDATORY (MUST BE CAREFULLY CHECKED AND PROPERLY SET!)
-- ========================================================================

-- Name of this instance, defaults to name of config file
-- ------------------------------------------------------------------------
config.instance_name = "Liquid · Instance name"


-- Information about service provider (HTML)
-- ------------------------------------------------------------------------
config.app_service_provider = "Snake Oil<br/>10000 Berlin<br/>Germany"


-- A rocketwiki formatted text the user has to accept while registering
-- ------------------------------------------------------------------------
config.use_terms = "=== Terms of Use ==="

-- Privacy Terms (HTML)
config.privacy_terms = "<h1>Datenschutzerklärung für das Liquid</h1>"
  
-- Absolute base url of application
-- ------------------------------------------------------------------------
config.absolute_base_url = "http://localhost/"

-- Checkbox(es) the user has to accept while registering
-- ------------------------------------------------------------------------
config.use_terms_checkboxes = {
  {
    name = "terms_of_use_v1",
    html = "I accept the terms of use.",
    not_accepted_error = "You have to accept the terms of use to be able to register."
  },
  {
    name = "extra_terms_of_use_v1",
    html = "Ich akzeptiere die <a href=\"" .. config.absolute_base_url .. "index/privacy.html\">Datenschutzerklärung</a>.",
    not_accepted_error = "Um dich zu registrieren, musst du die <a href=\"" .. config.absolute_base_url .. "index/privacy.html\">Datenschutzerklärung</a> akzeptieren."
  }
}

-- Connection information for the Liquid database
-- ------------------------------------------------------------------------
config.database = { engine='postgresql', dbname='uniliquid' }


-- Location of the rocketwiki binaries
-- ------------------------------------------------------------------------
config.formatting_engine_executeables = {
  rocketwiki= "/opt/rocketwiki-lqfb/rocketwiki-lqfb",
  compat = "/opt/rocketwiki-lqfb/rocketwiki-lqfb-compat"
}

-- ========================================================================
-- OPTIONAL
-- Remove leading -- to use a option
-- ========================================================================

-- List of enabled languages, defaults to available languages
-- ------------------------------------------------------------------------
config.enabled_languages = { 'de', 'en' } --, 'hu', 'el', 'eo', 'it', 'nl', 'zh-Hans', 'zh-TW' }

-- Default language, defaults to "en"
-- ------------------------------------------------------------------------
config.default_lang = "de"

-- after how long is a user considered inactive and the trustee will see warning,
-- notation is according to postgresql intervals, default: no warning at all
-- ------------------------------------------------------------------------
config.delegation_warning_time = '5 months'

-- Prefix of all automatic mails, defaults to "[Liquid] "
-- ------------------------------------------------------------------------
config.mail_subject_prefix = "[Liquid] "

-- Sender of all automatic mails, defaults to system defaults
-- ------------------------------------------------------------------------
config.mail_noreply = "noreply@localhost"
config.mail_envelope_from = "liquidsupport@localhost"
config.mail_from = { name = "Liquid", address = "liquidsupport@localhost" }
config.mail_reply_to = "liquidsupport@localhost"

-- Supply custom url for avatar/photo delivery
-- ------------------------------------------------------------------------
-- config.fastpath_url_func = nil
--config.fastpath_url_func = function(member_id, image_type)
--  return request.get_absolute_baseurl() .. "fastpath/getpic?" .. tostring(member_id) .. "+" .. tostring(image_type)
--end

-- Local directory for database dumps offered for download
-- ------------------------------------------------------------------------
config.download_dir = "/opt/uniliquid_dumps/"

config.avatar_dir = "/opt/uniliquid_frontend/static/avatars/"

-- Special use terms for database dump download
-- ------------------------------------------------------------------------
config.download_use_terms = "==== Nutzungsbedingungen Downloads ===="

-- Set public access level
-- Available options: false, "anonymous", "pseudonym", "full"
-- Defaults to "full"
-- ------------------------------------------------------------------------
config.public_access = "anonymous"

-- Use custom image conversion, defaults to ImageMagick's convert
-- ------------------------------------------------------------------------
--config.member_image_content_type = "image/jpeg"
config.member_image_convert_func = {
  avatar = function(data) return extos.pfilter(data, "convert", "jpeg:-", "-thumbnail",   "48x48", "jpeg:-") end,
  photo =  function(data) return extos.pfilter(data, "convert", "jpeg:-", "-thumbnail", "240x240", "jpeg:-") end
}

-- Display a public message of the day
-- ------------------------------------------------------------------------
--config.motd_public = 'MOTD'

-- Automatic issue related discussion URL
-- ------------------------------------------------------------------------
--config.issue_discussion_url_func = function(issue)
--   return config.absolute_base_url .. "f?" .. tostring(issue.id)
--end

-- Automatic issue related reddit URL
-- ------------------------------------------------------------------------
--config.issue_reddit_url_func = function(issue)
--   return config.absolute_base_url .. "r?" .. tostring(issue.id)
--end

-- Integration of Etherpad, disabled by default
-- ------------------------------------------------------------------------
--config.etherpad = {
--  base_url = "http://example.com:9001/",
--  api_base = "http://localhost:9001/",
--  api_key = "mysecretapikey",
--  group_id = "mygroupname",
--  cookie_path = "/"
--}

-- WebMCP accelerator
-- uncomment the following two lines to use C implementations of chosen
-- functions and to disable garbage collection during the request, to
-- increase speed:
-- ------------------------------------------------------------------------
require 'webmcp_accelerator'
-- if cgi then collectgarbage("stop") end

-- Trace debug
-- uncomment the following line to enable debug trace
-- ------------------------------------------------------------------------
-- config.enable_debug_trace = true

config.footer_html = ""

-- ========================================================================
-- Do main initialisation (DO NOT REMOVE FOLLOWING SECTION)
-- ========================================================================
--config.free_timing = {
--  calculate_func = function(policy, timing_string)
--    function interval_by_seconds(secs)
--      local days = math.floor(secs / 86400)
--      secs = secs - days * 86400
--      return days .. " days " .. secs .. " seconds"
--    end
--    local year, month, day, hour = string.match(timing_string, "^%s*([0-9]+)%-([0-9]+)%-([0-9]+)% ([0-9]+)%:00:00s*$")
--    local target_date = os.time{year=tonumber(year), month=tonumber(month), day=tonumber(day), hour=tonumber(hour)}
--    if not target_date then
--      return false
--    end
--    local now = os.time(os.date("*t"))
--    local duration = target_date - now
--    if duration < 0 then
--      return false
--    end
--    return {
--      admission = interval_by_seconds(3600),
--      discussion = interval_by_seconds(3600),
--      verification = interval_by_seconds(3600),
--      voting = interval_by_seconds(duration-7200)
--    }
--  end,
--  available_func = function(policy)
--    local policies = {}
--    local time = os.time(os.date("*t"))
--    for i = 0, 30 do
--      for j = 0,23 do
--        local now = os.date("*t",time)
--        policies[i*24+j] = { name = now.day .. "." .. now.month .. "." .. now.year .. " -- " .. now.hour .. " Uhr", id = now.year .. "-" .. now.month .. "-" .. now.day .. " " .. now.hour .. ":00:00" }
--        time = time + 3600
--      end
--    end
--    return policies
--  end
--}

config.forbid_similar_names = false
config.max_nick_length = 60

config.mv_connection = false
--config.mv_decryption_url = "https://admidio_url/adm_api/usr.php?user_id="
--config.mv_name = "Admidio"

config.invite_text_file = "/opt/uniliquid_frontend/config/invite_mail.txt"
config.invite_subject = "[Liquid] Einladung ins Liquid"

execute.config("init")

-- comment this out when going productive
local member = Member:by_id(1)
if member == nil then
  member = Member:new()
  member.login = 'admin'
  member.name = 'admin'
  member.admin = true
  member:set_password('admin')
  member.activated = 'now'
  member.active = true
  member.last_activity = 'now'
  member:save()
end

config.default_privilege_for_unit = 0

config.register_without_invite_code = true
