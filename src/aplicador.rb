require_relative 'interceptor'

class Condicion
  def initialize(&bloque)
    @bloque = bloque
  end

  def y(otra_condicion)
    join(:&, otra_condicion)
  end

  def join(operador, otra_condicion)
    Condicion.new { |target, method|
      self.matches(target, method).send :operador, otra_condicion.matches(target, method)
    }
  end

  def o(otra_condicion)
    join(:|, otra_condicion)
  end

  def matches(target, method)
    @condicion.call(target, method)
  end

  def aplicar(comportamiento)
    @comportamiento = comportamiento
  end

  def aplicar_si_corresponde(target, method)
    if(self.matches(target, method))
      @comportamiento.aplicar_a_metodo(target, method)
    end
  end
end

class CondicionBuilder
  def es(clase)
    Condicion.new { |target, method| target == clase || target.instance_of?(clase) }
  end

  def es_subclase(clase)
    incluye_ancestro clase
  end

  def comienza_con(sym)
    Condicion.new { |target, method| method.to_s.start_with? sym.to_s }
  end

  def incluye_ancestro(ancestro)
    Condicion.new { |target, method| target.ancestors.include? ancestro }
  end

  def tiene_mixin(mixin)
    incluye_ancestro mixin
  end
end

module Aplicador
  @condiciones = []

  def self.en_clase(&bloque)
    self.nueva_condicion bloque
  end

  def nueva_condicion(bloque)
    condicion = CondicionBuilder.new.instance_eval &bloque
    @condiciones << condicion
    condicion
  end

  def self.en_metodo(&bloque)
    self.nueva_condicion bloque
  end

  def procesar(targets)
    @condiciones.each do |condicion|
      targets.each do |target|
        Interceptor.interceptable_methods(target).each do |method|
          condicion.aplicar_si_corresponde(target, method)
        end
      end
    end
  end

end