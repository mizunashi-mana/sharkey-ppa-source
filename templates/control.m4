Source: sharkey
Section: web
Priority: optional
Maintainer: Mizunashi Mana <contact@mizunashi.work>
Rules-Requires-Root: no
Build-Depends:
  debhelper-compat (= 12),
  rsync,
  nodejs (>= __NODE_MAJOR_VERSION__.0.0),
Standards-Version: 4.6.2
Homepage: https://joinsharkey.org
Vcs-Git: https://activitypub.software/TransFem-org/Sharkey.git
Vcs-browser: https://activitypub.software/TransFem-org/Sharkey

Package: sharkey
Architecture: any
Depends:
  nodejs (>= __NODE_MAJOR_VERSION__.0.0),
  ffmpeg,
  ${misc:Depends},
Suggests:
  postgresql,
  redis,
Description: Sharkey is an open source, decentralized social media platform that's free forever!
