if defined?(Slackistrano::Messaging)
   module Slackistrano
     class CustomMessaging < Messaging::Base

      # Suppress starting message.
      def payload_for_updating

        attachments = []
        # rollback / deployを判定する為、before startingのcallbackで判定を取得する
        title = fetch(:deploying, false) ? 'deploying' : 'rollback now'
        color = fetch(:deploying, false) ? 'warning' : 'danger'

        # https://github.com/phallstrom/slackistrano
        attachments = attachments_base(title: title, color: color)

        # git log
        attachments << {
          color:  color,
          title:  "git log",
          fields: git_last_commits_fields
        }

        return {attachments: attachments}
      end

      # Suppress updated message.
      def payload_for_updated
        attachments = [] + attachments_base(title: 'Deploy complete', color: 'good')
        return {attachments: attachments}
      end

      # Supperss reverting message.
      def payload_for_reverting
        # Delegate payload_for_updating
      end

      # Suppress reverted message.
      def payload_for_reverted
        attachments = [] + attachments_base(title: 'Revert complete', color: 'good')
        return {attachments: attachments}
      end

      # Suppress failred message.
      def payload_for_failed
        attachments = [] + attachments_base(title: 'Deploy failred', color: 'good')

        # エラー内容を取得
        exception = fetch(:failed_exception)
        trace_message = exception.inspect + "\n" + exception.backtrace.join("\n")

        # エラー内容
        attachments << {
          color: 'danger',
          title: "エラー内容",
          fields: [{
            value: trace_message
          }]
        }
        return {attachments: attachments}
      end

      private
        def attachments_base(title = "", color = "")
          {
            color: color,
            title: "#{application} #{title}",
            fields: [
              {
                title: '環境',
                value: stage,
                short: true
              },
              {
                title: 'ブランチ',
                value: branch,
                short: true
              },
              {
                title: 'Capistrano実行者',
                value: deployer,
                short: true
              },
              {
                title: '実行時間',
                value: elapsed_time,
                short: true
              }
            ],
            fallback: super[:text]
          }
        end

        def deployer
          `whoami`.strip
        end
    end
  end
end
