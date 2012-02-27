class JoinRequest < Admission
  validates_presence_of :candidate_id, :candidate_type
  attr_accessible :candidate, :group, :email, :comment, :processed, :accepted, :role_id, :introducer
end
