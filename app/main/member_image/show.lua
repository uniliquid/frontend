local image_type = param.get("image_type")
local record = MemberImage:by_pk(param.get_id(), image_type, true)

-- use avatar if no photo
if record == nil and image_type == "photo" then
  image_type = "avatar"
  record = MemberImage:by_pk(param.get_id(), image_type, true)
end

print('Cache-Control: max-age=86400'); -- let the client cache the image for 5 minutes

if record == nil then
  record = { data = "", content_type = "image/jpeg" }
  local default_file = ({ avatar = config.avatar_dir .. "u" .. param.get_id() .. ".jpg", photo = nil })[image_type]
  local f = io.open(default_file, "rb")
  record.data = f:read("*all")
  record.content_type = "image/jpeg"
  f:close()
end

assert(record.content_type, "No content-type set for image.")

slot.set_layout(nil, record.content_type)

if record then
  slot.put_into("data", record.data)
end
