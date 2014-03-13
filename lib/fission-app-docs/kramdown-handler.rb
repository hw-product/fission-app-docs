require 'kramdown'

module FissionApp
  module Docs
    module Kramdown

      class << self

        def erb
          @erb ||= ActionView::Template.registered_template_handler(:erb)
        end

        def call(template)
          compiled_source = erb.call(template)
          "Kramdown::Document.new(begin;#{compiled_source};end).to_html.html_safe"
        end

      end

    end
  end
end

ActionView::Template.register_template_handler :md, FissionApp::Docs::Kramdown
