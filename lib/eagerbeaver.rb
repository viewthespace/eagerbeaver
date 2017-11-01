require "eagerbeaver/version"

class EagerBeaver
  def initialize(model, preloads)
    @model = model
    @preloads = Array(preloads)
  end

  def errors
    trace(model, preloads).flatten.compact
  end

  private

  def trace(model, assoc)
    model_string = model.to_s.singularize.classify

    if assoc.is_a?(Array)
      assoc.map { |a| trace(model, a) }
    elsif assoc.is_a?(Hash)
      val = Array(trace(association_name(model_string, assoc.keys.first), assoc.values.first))
      val << trace(model, assoc.keys.first)
    elsif assoc.is_a?(Symbol) && !model_string.constantize.reflect_on_all_associations.map(&:name).include?(assoc)
      "#{assoc} is not an association of #{model_string}"
    end
  end

  def association_name(model_string, association_name_or_alias)
    association = model_string.constantize.reflect_on_all_associations.find { |a| a.name == association_name_or_alias }
    association.try(:source_reflection_name) ||
      association.try(:options).try(:[], :class_name) ||
      association_name_or_alias
  end

  attr_reader :model, :preloads
end
