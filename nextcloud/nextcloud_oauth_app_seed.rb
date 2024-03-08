# frozen_string_literal: true

#  Copyright (c) 2023, Schweizerischer Kanu-Verband. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

Oauth::Application.seed(:name, :uid, :secret,
  {
    name: 'Nextcloud',
    uid: ENV['NEXTCLOUD_OIDC_CLIENT_ID'],
    secret: ENV['NEXTCLOUD_OIDC_CLIENT_SECRET'],
    redirect_uri: 'http://localhost/apps/user_oidc/code',
    scopes: 'email openid nextcloud',
  }
)
