require_relative 'interceptor'

class Metric

  attr_reader :tiempo

  def initialize(target, method_sym, delta)
    @target = target
    @method_sym = method_sym
    @tiempo = delta
  end

  def matches(some_target, method_sym)
    @method_sym == method_sym && Interceptor.matches_target(@target, some_target)
  end
end

class Profiler

  def initialize
    @metrics = []
  end

  def profile(target, method_sym)
    start_time = nil
    profiler = self

    before = proc { |*args, &block|
      start_time = Time.now.nsec
    }

    after = proc { |result|
      profiler.new_metric(self, method_sym, Time.now.nsec - start_time)
    }

    Interceptor.intercept(target, method_sym, before, after)
  end

  def tiempo_promedio(target, method_sym)
    matching_metrics = @metrics.find_all { |metric|
      metric.matches(target, method_sym)
    }

    tiempo_total = matching_metrics.reduce(0) { |acum, metric|
      acum + metric.tiempo
    }

    tiempo_total / matching_metrics.size
  end

  def new_metric(target, method_sym, delta)
    @metrics << Metric.new(target, method_sym, delta)
  end

  def self.aplicar_a_metodo(target, method)
    profiler = Profiler.new
    profiler.profile(target,method)

    profiler
  end
end