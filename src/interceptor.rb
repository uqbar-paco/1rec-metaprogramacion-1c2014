module Interceptor
  def self.is_interceptable?(method_sym)
    #Quitamos los métodos de object, porque sino se hace muy complicado.
    #Habría que hacer algún algoritmo más inteligente igual
    !Object.instance_methods.include? method_sym
  end

  def self.intercept(target, method_sym, before=nil, after=nil)
    get_target_class(target).intercept(method_sym, before, after)
  end

  def self.intercept_all(target, before=nil, after=nil)
    clazz = get_target_class(target)
    self.interceptable_methods(clazz).each do |method_sym|
      clazz.intercept(method_sym, before, after)
    end
  end

  def self.interceptable_methods(clazz)
    clazz.instance_methods.find_all do |a_method|
      self.is_interceptable? a_method
    end
  end

  def self.get_target_class(target)
    target.instance_of?(Class) ? target : target.singleton_class
  end

  def self.matches_target(target, other_target)
    target == other_target || (other_target.instance_of?(Class) && target.instance_of?(other_target))
  end
end

class Class
  def intercept(method_sym, before, after)
    old_method = self.instance_method method_sym
    self.send(:define_method, method_sym) { |*args, &block|
      self.instance_eval(&before) unless before.nil?
      bound_method = old_method.bind(self)
      result = bound_method.call(*args, &block)
      self.instance_eval(&after) unless after.nil?
      result
    }
  end
end