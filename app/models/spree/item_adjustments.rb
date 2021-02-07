# frozen_string_literal: true

module Spree
  # Manage (recalculate) item (LineItem or Shipment) adjustments
  class ItemAdjustments
    attr_reader :item

    delegate :adjustments, :order, to: :item

    def initialize(item)
      @item = item
    end

    def update
      update_adjustments if item.persisted?
      item
    end

    def update_adjustments
      tax_adjustments =
        (item.respond_to?(:all_adjustments) ? item.all_adjustments : item.adjustments).tax

      adjustment_total = adjustments.additional.map(&:update!).compact.sum
      included_tax_total = tax_adjustments.inclusive.reload.map(&:update!).compact.sum
      additional_tax_total = tax_adjustments.additional.reload.map(&:update!).compact.sum

      item.update_columns(
        included_tax_total: included_tax_total,
        additional_tax_total: additional_tax_total,
        adjustment_total: adjustment_total,
        updated_at: Time.zone.now
      )
    end
  end
end
