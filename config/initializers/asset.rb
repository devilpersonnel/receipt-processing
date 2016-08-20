Rails.application.config.assets.precompile << /\.(?:png|jpg|jpeg|gif)\z/

# Fonts
Rails.application.config.assets.precompile << /\.(?:svg|eot|woff|ttf)\z/