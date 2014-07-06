require_relative 'interceptor'

module Activable
  def desactivar
    @activado = false
  end

  def activar
    @activado = true
  end

  def is_activado?
    instance_variable_defined?(:@activado) ? @activado : true
  end
end

module Activador
  @before = proc {
    raise "Desactivado" unless self.is_activado?
  }

  def self.aplicar_a(target)
    Interceptor.intercept_all(target, @before)

    Interceptor.get_target_class(target).send :include, Activable
  end

  def self.aplicar_a_metodo(target, method)
    Interceptor.intercept(target, method, @before)
    Interceptor.get_target_class(target).send :include, Activable
  end
end