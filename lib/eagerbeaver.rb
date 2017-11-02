require "eagerbeaver/version"

class EagerBeaver
  def initialize(model, preloads)
    @model = model
    @preloads = preloads
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
    association = match_association(model_string.to_s, association_name_or_alias)
    return association_name_or_alias unless association

    options = association.options

    if options[:through] && options[:source]
      source = options[:source_type] || options[:source]
      through = association_name(model_string, options[:through]) ||
        association_name(options[:through], source)
      association_name(through, source)
    else
      options[:class_name] || association_name_or_alias
    end
  end

  def match_association(model_string, association)
    constantize(model_string).reflect_on_all_associations.find { |a| a.name == association }
  end

  def constantize(model_string)
    if model_string.first == model_string.first.upcase
      model_string.singularize.constantize
    else
      model_string.split('_').map(&:capitalize).join.singularize.constantize
    end
  end

  attr_reader :model, :preloads
end
