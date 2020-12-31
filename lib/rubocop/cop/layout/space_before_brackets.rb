# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks for space between the name of a receiver and a left
      # brackets.
      #
      # @example
      #
      #   # bad
      #   collection [index_or_key]
      #
      #   # good
      #   collection[index_or_key]
      #
      class SpaceBeforeBrackets < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Remove the space before the opening brackets.'

        def on_send(node)
          return unless (first_argument = node.first_argument)

          begin_pos = first_argument.source_range.begin_pos
          return unless (range = offense_range(node, begin_pos))

          register_offense(range)
        end

        private

        def offense_range(node, begin_pos)
          if reference_variable_with_brackets?(node)
            receiver_end_pos = node.receiver.source_range.end_pos
            selector_begin_pos = node.loc.selector.begin_pos
            return if receiver_end_pos >= selector_begin_pos

            range_between(receiver_end_pos, selector_begin_pos)
          elsif node.method?(:[]=)
            end_pos = node.receiver.source_range.end_pos

            return if begin_pos - end_pos == 1

            range_between(end_pos, begin_pos - 1)
          end
        end

        def register_offense(range)
          add_offense(range) do |corrector|
            corrector.remove(range)
          end
        end

        def reference_variable_with_brackets?(node)
          node.receiver&.variable? && node.method?(:[]) && node.arguments.size == 1
        end
      end
    end
  end
end