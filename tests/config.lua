-- Test only (tests/run.sh): the frontend's settings for the tests, like
-- the deployment's placeholders without site settings. Synthetic values.
config.absolute_base_url = "https://lf.example.org/"
config.instance_name = "Test"
config.app_service_provider = ""
config.use_terms = "=== Terms of use ==="
config.privacy_terms = ""
config.download_use_terms = "=== Terms of use of the downloads ==="
config.use_terms_checkboxes = {}
config.enabled_languages = { 'de', 'en' }
config.default_lang = "en"
config.public_access = "anonymous"
config.delegation_warning_time = '5 months'
config.footer_html = ""
config.forbid_similar_names = false
config.max_nick_length = 60
config.mv_connection = false
config.register_without_invite_code = false
config.enable_forum_scripts = false
config.use_lfbot_reddit_buffer = false
config.linkmenu = {}
config.default_privilege_for_unit = 0
config.database = { engine = 'postgresql', dbname = 'liquid_feedback' }
-- As deployed without site settings: the C implementations of WebMCP.
require 'webmcp_accelerator'

execute.config("init")
