# -*- coding: utf-8 -*-

Plugin.create(:list_datasource) do

    @lists = []

    # データソースとして提供するリストを記録する
    on_boot do |service|
        service.lists.next do |lists|
            lists.each do |list|
                @lists.push(list)
            end
        end
    end

    # データソースの情報を挿入
    filter_extract_datasources { |ds|
        datasources = {}
        @lists.each { |list|
            datasources["@#{list.user}/#{list[:name]}".to_sym] = "@#{list.user}/#{list[:name]}"
        }
        [ds.merge(datasources)]
    }

    # 受け取ったメッセージを、リスト情報によって振り分ける
    on_list_update do |list, messages|
        messages.each do |message|
            Plugin.call(:extract_receive_message, "@#{list.user}/#{list[:name]}".to_sym, [message])
        end
    end
end
