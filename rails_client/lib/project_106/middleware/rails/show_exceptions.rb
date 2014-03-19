module Project106
  module Middleware
    module Rails
      module ShowExceptions
        include ExceptionReporter

        # catching rails middleware render_exception method call and
        # doing project-106 error catching task and
        # again continue with rails render_exception method
        def render_exception_with_project_106(env, exception)
          key = 'action_dispatch.show_detailed_exceptions'

          # don't report production exceptions here as it is done below
          # in call_with_project_106() when show_detailed_exception is false
          if not env.has_key?(key) or env[key]
            # sending exception to project-106 to collect exception data
            report_exception_to_project_106(env, exception)
          end
          render_exception_without_project_106(env, exception)
        end

        def call_with_project_106(env)
          call_without_project_106(env)
        rescue => exception
          # won't reach here if show_detailed_exceptions is true
          report_exception_to_project_106(env, exception)
          raise exception
        end

        def self.included(base)
          base.send(:alias_method_chain, :call, :project_106)
          base.send(:alias_method_chain, :render_exception, :project_106)
        end
      end
    end
  end
end
