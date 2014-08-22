# We have had lots of config issues with SECRET_TOKEN to avoid this mess we are moving it to redis
#  if you feel strongly that it does not belong there use ENV['SECRET_TOKEN']
#
# token = ENV['SECRET_TOKEN']
# unless token
#   token = $redis.get('SECRET_TOKEN')
#   unless token && token.length == 128
#     token = SecureRandom.hex(64)
#     $redis.set('SECRET_TOKEN',token)
#   end
# end
# 
# Discourse::Application.config.secret_token = token
#secret_key_base
#

Discourse::Application.config.secret_key_base = 'cdaa5ee6b57be673d4bb53fa668fb2faea7605fce0be8e09918d412fa16c82112be9c175cd4d9eedc462fe9d0736421ed1a61032dd32af4531b56dd65220488c'
