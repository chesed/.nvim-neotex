-- neotex.plugins.ai.claude.extensions.loader
-- Claude file copy engine (delegates to shared)

local shared_loader = require("neotex.plugins.ai.shared.extensions.loader")

-- Re-export all shared loader functions directly
return shared_loader
