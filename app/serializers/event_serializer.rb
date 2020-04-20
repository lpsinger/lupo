
class EventSerializer
  include FastJsonapi::ObjectSerializer
  # include BatchLoaderHelper

  set_key_transform :camel_lower
  set_type :events
  set_id :uuid
  
  attributes :subj_id, :obj_id, :source_id, :target_doi, :relation_type_id, :source_relation_type_id, :target_relation_type_id, :total, :message_action, :source_token, :license, :occurred_at, :timestamp

  attribute :timestamp, &:updated_at

  attribute :source_doi do |object|
    object.source_doi.downcase if object.source_doi.present?
  end

  attribute :target_doi do |object|
    object.target_doi.downcase if object.target_doi.present?
  end
end
