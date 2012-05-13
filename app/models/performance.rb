# Performance define the Role some Actor is playing in some Stage
#
# == Named scopes
#
# stage_type(type): find Peformances by Stage type
#
# == Only one with highest Role
# When there is only one Performance in some stage with the highest Role, the callbacks :avoid_downgrading_only_one_with_highest_role and :avoid_destroying_only_one_with_highest_role prevents the Stage runs out of Agents performing the highest Role.
#
# E.g., in a Space, the only Administrator can't change his Role to a lower one and can't leave the Space without assigning a new Administrator

class Performance < ActiveRecord::Base
end
