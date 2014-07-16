-- ========================================================================
-- MANDATORY (MUST BE CAREFULLY CHECKED AND PROPERLY SET!)
-- ========================================================================

-- Name of this instance, defaults to name of config file
-- ------------------------------------------------------------------------
config.instance_name = "Public Software Group e.V."


-- Information about service provider (HTML)
-- ------------------------------------------------------------------------
config.app_service_provider = "Snake Oil<br/>10000 Berlin<br/>Germany"


-- A HTML formatted text the user has to accept while registering
-- ------------------------------------------------------------------------
config.use_terms = "<h1>Terms of Use</h1><p>Insert terms here</p>"


-- Checkbox(es) the user has to accept while registering
-- ------------------------------------------------------------------------
config.use_terms_checkboxes = {
  {
    name = "terms_of_use_v1",
    html = "I accept the terms of use.",
    not_accepted_error = "You have to accept the terms of use to be able to register."
  },
--  {
--    name = "extra_terms_of_use_v1",
--    html = "I accept the extra terms of use.",
--    not_accepted_error = "You have to accept the extra terms of use to be able to register."
--  }
}

  
-- Absolute base url of application
-- ------------------------------------------------------------------------
config.absolute_base_url = "http://192.168.1.34/lf3/"


-- Connection information for the LiquidFeedback database
-- ------------------------------------------------------------------------
config.database = { engine='postgresql', dbname='liquid_feedback' }
config.database = { engine='postgresql', dbname='lftest' }


-- Location of the rocketwiki binaries
-- ------------------------------------------------------------------------
config.enforce_formatting_engine = "markdown2"

config.formatting_engines = {
  { id = "markdown2",
    name = "python-markdown2",
    executable = "markdown2",
    args = {'-s', 'escape', '-x', 'nofollow,wiki-tables'},
    remove_images = true
  },
  { id = "markdown_py",
    name = "Python Markdown",
    executable = "markdown_py",
    args = {'-s', 'escape', '-x', 'extra', '-x', 'nl2br', '-x', 'sane_lists'},
    remove_images = true
  },
  { id = "rocketwiki",
    name = "RocketWiki",
    executable = "/opt/rocketwiki-lqfb/rocketwiki-lqfb",
    remove_images = false
  },
  { id = "compat",
    name = "Traditional WIKI syntax",
    executable = "/opt/rocketwiki-lqfb/rocketwiki-lqfb-compat",
    remove_images = false
  }
}

-- Public access level
-- ------------------------------------------------------------------------
-- Available options:
-- "none" 
--     -> Closed user group, no public access at all
--        (except login/registration/password reset)
-- "anonymous"
--     -> Shows only initiative/suggestions texts and aggregated
--        supporter/voter counts
-- "authors_pseudonymous" 
--     -> Like anonymous, but shows screen names of authors
-- "all_pseudonymous" 
--     -> Show everything a member can see, except profile pages
-- "everything"
--     -> Show everything a member can see, including profile pages
-- ------------------------------------------------------------------------
config.public_access = "all_pseudonymous"



-- ========================================================================
-- OPTIONAL
-- Remove leading -- to use a option
-- ========================================================================

-- List of enabled languages, defaults to available languages
-- ------------------------------------------------------------------------
-- config.enabled_languages = { 'en', 'de', 'eo', 'el', 'hu', 'it', 'nl', 'zh-TW' }

-- Default language, defaults to "en"
-- ------------------------------------------------------------------------
-- config.default_lang = "de"

-- after how long is a user considered inactive and the trustee will see warning,
-- notation is according to postgresql intervals, default: no warning at all
-- ------------------------------------------------------------------------
config.delegation_warning_time = '1 hour'

-- after which time a user is suggested to (_soft) or forced to (_hard) 
-- confirm unit and area delegations. default: no confirmation at all
-- ------------------------------------------------------------------------
-- config.check_delegations_interval_hard = "1 day"
-- config.check_delegations_interval_soft = "3 seconds"

-- default options should be checked when confirming delegations
-- options: "confirm", "revoke" and "none"
-- ------------------------------------------------------------------------
-- config.check_delegations_default = "confirm"

-- Prefix of all automatic mails, defaults to "[Liquid Feedback] "
-- ------------------------------------------------------------------------
-- config.mail_subject_prefix = "[LiquidFeedback] "

-- Sender of all automatic mails, defaults to system defaults
-- ------------------------------------------------------------------------
-- config.mail_envelope_from = "liquidfeedback@example.com"
-- config.mail_from = { name = "LiquidFeedback", address = "liquidfeedback@example.com" }
-- config.mail_reply_to = { name = "Support", address = "support@example.com" }

-- Configuration of password hashing algorithm (defaults to "crypt_sha512")
-- ------------------------------------------------------------------------
-- config.password_hash_algorithm = "crypt_sha512"
-- config.password_hash_algorithm = "crypt_sha256"
-- config.password_hash_algorithm = "crypt_md5"

-- Number of rounds for crypt_sha* algorithms, minimum and maximum
-- (defaults to minimum 10000 and maximum 20000)
-- ------------------------------------------------------------------------
-- config.password_hash_min_rounds = 10000
-- config.password_hash_max_rounds = 20000

-- Supply custom url for avatar/photo delivery
-- ------------------------------------------------------------------------
-- config.fastpath_url_func = nil

-- Local directory for database dumps offered for download
-- ------------------------------------------------------------------------
-- config.download_dir = nil

-- Special use terms for database dump download
-- ------------------------------------------------------------------------
-- config.download_use_terms = "=== Download use terms ===\n"

-- Use custom image conversion, defaults to ImageMagick's convert
-- ------------------------------------------------------------------------
--config.member_image_content_type = "image/jpeg"
--config.member_image_convert_func = {
--  avatar = function(data) return extos.pfilter(data, "convert", "jpeg:-", "-thumbnail",   "48x48", "jpeg:-") end,
--  photo =  function(data) return extos.pfilter(data, "convert", "jpeg:-", "-thumbnail", "240x240", "jpeg:-") end
--}

config.member_image_content_type = "image/jpeg"
config.member_image_convert_func = {
  avatar = function(data) return extos.pfilter(data, "convert",
    "jpeg:-",
    "-set", "option:distort:viewport", 
    "%[fx:min(w,h)]x%[fx:min(w,h)]+%[fx:max((w-h)/2,0)]+%[fx:max((h-w)/2,0)]",
    "-filter", "point",
    "-distort", "SRT", "0", 
    "+repage",
    "-define", "filter:filter=Sinc", 
    "-define", "filter:window=Jinc",
    "-define", "filter:lobes=3",
    "-thumbnail", "48x48",
    "jpeg:-"
  ) end,
  photo =  function(data) return extos.pfilter(data, "convert",
    "jpeg:-",
    "-define", "filter:filter=Sinc", 
    "-define", "filter:window=Jinc",
    "-define", "filter:lobes=3",
    "-thumbnail", "240x240",
    "jpeg:-"
  ) end
}


-- Display a html formatted public message of the day
-- ------------------------------------------------------------------------
-- config.motd_public = "<h1>Message of the day (public)</h1><p>The MOTD is formatted with HTML</p>"

-- Display a html formatted internal message of the day
-- ------------------------------------------------------------------------
-- config.motd_intern = "<h1>Message of the day (intern)</h1><p>The MOTD is formatted with HTML</p>"

-- Automatic issue related discussion URL
-- ------------------------------------------------------------------------
-- config.issue_discussion_url_func = function(issue)
--   return "http://example.com/discussion/issue_" .. tostring(issue.id)
-- end

-- Configuration of "tell others"
-- ------------------------------------------------------------------------
config.tell_others = {
  initiative = function (initiative)
    local text = "i" .. initiative.id .. ": " .. initiative.name .. " " .. request.get_absolute_baseurl() .. "initiative/" .. initiative.id .. ".html"
    return {
      { content = "tweet this initiative", external = "https://twitter.com/intent/tweet?text=" .. encode.url_part(text) },
      { content = "send link with e-mail", external = "mailto:?subject=" .. encode.url_part(initiative.display_name) .. "&body=" .. encode.url_part(text) }
    }
  end
}

-- Integration of Etherpad, disabled by default
-- ------------------------------------------------------------------------
--config.etherpad = {
--  base_url = "http://example.com:9001/",
--  api_base = "http://localhost:9001/",
--  api_key = "mysecretapikey",
--  group_id = "mygroupname",
--  cookie_path = "/"
--}

-- Free timings, may be used together with polling policies
-- ------------------------------------------------------------------------
-- This example expects a date string entered in the free timing field
-- by the user creating a poll, interpreting it as target date for then
-- poll and splits the remainig time at the ratio of 4:1:2
-- Please note, polling policies never have an admission phase


config.free_timing = {
  calculate_func = function(policy, timing_string)
    function interval_by_seconds(secs)
      local secs_per_day = 60 * 60 * 24
      local days
      days = math.floor(secs / secs_per_day)
      secs = secs - days * secs_per_day
      return days .. " days " .. secs .. " seconds"
    end
    local target_date = parse.date(timing_string, atom.date)
    if not target_date then
      return false
    end
    local target_timestamp = target_date.midday
    local now = atom.timestamp:get_current()
    trace.debug(target_timestamp, now)
    local duration = target_timestamp - now
    if duration < 0 then
      return false
    end
    return {
      discussion = interval_by_seconds(duration / 7 * 4),
      verification = interval_by_seconds(duration / 7 * 1),
      voting = interval_by_seconds(duration / 7 * 2)
    }
  end,
  available_func = function(policy)
    return { 
      { name = "End of 2013", id = '2013-12-31' },
      { name = "End of 2014", id = '2014-12-31' },
      { name = "End of 2015", id = '2015-12-31' }
    }
  end
}


config.enable_debug_trace = true

-- WebMCP accelerator
-- uncomment the following two lines to use C implementations of chosen
-- functions and to disable garbage collection during the request, to
-- increase speed:
-- ------------------------------------------------------------------------
-- require 'webmcp_accelerator'
-- if cgi then collectgarbage("stop") end


-- ========================================================================
-- Do main initialisation (DO NOT REMOVE FOLLOWING SECTION)
-- ========================================================================

execute.config("init")
