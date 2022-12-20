
 local _local_2_ do local _1_ = require("pact.lib.ruin.type") _local_2_ = _1_ end local _local_3_ = _local_2_ local string_3f = _local_3_["string?"]

 local function sha_3f(sha)
 return (string_3f(sha) and (40 == #string.match(sha, "^(%x+)$"))) end


 local function version_3f(v)
 return (string_3f(v) and ((nil ~= string.match(v, "^(%d+)$")) or (nil ~= string.match(v, "^(%d+%.%d+)$")) or (nil ~= string.match(v, "^(%d+%.%d+%.%d+)$")))) end




 local function version_spec_3f(v)
 return (string_3f(v) and (nil ~= string.match(v, "^[%^~><=]+%s?%d+%.%d+%.%d+$"))) end


 return {["valid-sha?"] = sha_3f, ["sha?"] = sha_3f, ["valid-version?"] = version_3f, ["version?"] = version_3f, ["valid-version-spec?"] = version_spec_3f, ["version-spec?"] = version_spec_3f}