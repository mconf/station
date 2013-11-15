require 'rails'

module Station
  require 'active_record/content/inquirer'
  require 'active_record/content/inquirer_proxy'
  require 'active_record/acts_as'
  require 'active_record/content'
  require 'active_record/resource'
  require 'active_record/taggable'

  require 'action_view/helpers/tags_helper'

  require 'action_controller/station'
  require 'action_controller/station_resources'

  require 'station/rails'
end
