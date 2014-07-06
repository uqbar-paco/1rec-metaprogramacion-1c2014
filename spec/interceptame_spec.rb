require 'rspec'
require_relative '../src/profiler'
require_relative '../src/activador'

describe 'Interceptame' do

  golondrina = nil

  declare_golondrina = lambda {
    golondrina = Class.new {
      attr_reader :energia

      def initialize
        @energia = 100
      end

      def volar
        @energia -= 10
      end

      def comer(energia)
        @energia += energia
      end
    }
  }

  pepita = nil

  before(:each) do
    declare_golondrina.call
    pepita = golondrina.new
  end

  describe "Profiler" do
    profiler = nil
    before(:each) do
      profiler = Profiler.new
    end

    it 'should do the default behaviour besides the profiling' do
      profiler.profile(pepita, :volar)

      pepita.volar
      pepita.energia.should equal 90

      profiler.profile(pepita, :comer)

      pepita.comer(120)
      pepita.energia.should equal 210
    end

    it 'should profile an object' do
      profiler.profile(pepita, :volar)

      pepita.volar

      profiler.tiempo_promedio(pepita, :volar).should be_a Numeric
    end

    it 'should profile a class' do
      otra_golondrina = golondrina.new
      profiler.profile(golondrina, :comer)
      profiler.profile(golondrina, :volar)

      otra_golondrina.comer(10)
      pepita.volar

      profiler.tiempo_promedio(golondrina, :comer).should be_a Numeric
      profiler.tiempo_promedio(golondrina, :volar).should be_a Numeric
    end
  end

  describe 'Activador' do

    it 'should do the default behaviour besides activation' do
      Activador.aplicar_a(pepita)

      pepita.volar
      pepita.energia.should equal 90

      pepita.comer(120)
      pepita.energia.should equal 210
    end

    it 'should raise error once deactivated' do
      Activador.aplicar_a(pepita)

      pepita.desactivar

      expect {pepita.volar}.to raise_error
    end

    it 'should be reactivable once deactivated' do
      Activador.aplicar_a(pepita)

      pepita.desactivar
      pepita.activar

      pepita.volar
    end
  end

end
