ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
begin
  require 'bootsnap/setup'
  env = ENV['RAILS_ENV'] || "development"
  Bootsnap.setup(
    cache_dir:            'tmp/cache',          # キャッシュファイルを保存する path
    development_mode:     env == 'development', # 現在の作業環境、例えば RACK_ENV, RAILS_ENV など。
    load_path_cache:      true,                 # キャッシュで LOAD_PATH を最適化する。
    autoload_paths_cache: true,                 # キャッシュで ActiveSupport による autoload を行う。
    disable_trace:        true,                 # (アルファ) `RubyVM::InstructionSequence.compile_option = { trace_instruction: false }`をセットする。
    compile_cache_iseq:   true,                 # ISeq キャッシュをコンパイルする
    compile_cache_yaml:   true                  # YAML キャッシュをコンパイルする
  )
rescue LoadError => e;
end # Speed up boot time by caching expensive operations.
