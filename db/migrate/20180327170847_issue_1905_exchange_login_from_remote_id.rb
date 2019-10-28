class Issue1905ExchangeLoginFromRemoteId < ActiveRecord::Migration[5.1]
  def change

    # return if it's a new setup
    return if !Setting.find_by(name: 'system_init_done')

    config = Import::Exchange.config
    return if config.blank?
    return if config[:attributes].blank?
    return if config[:attributes][:item_id].blank?
    return if config[:attributes][:item_id] != 'login'

    config[:attributes].delete(:item_id)

    Import::Exchange.config = config
  end
end
