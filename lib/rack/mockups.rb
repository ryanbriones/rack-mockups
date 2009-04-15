require 'rack'

module Rack
  class Mockups
    DEFAULT_RACK_VIEW_PATH = ::File.expand_path(Dir.pwd + '/views/mockups')
    DEFAULT_RAILS_VIEW_PATH = ::File.expand_path(Dir.pwd + '/app/views/mockups')

    def initialize(app)
      @app = app
      yield self if block_given?
      @root ||= self.class.const_defined?('RAILS_ROOT') ? DEFAULT_RAILS_VIEW_PATH : DEFAULT_RACK_VIEW_PATH
      @file_server = Rack::Mockups::File.new(@root)
    end

    def call(env)
      status, headers, body = @app.call(env)
      unless status >= 200 && status < 400
        status, headers, body = @file_server.call(env)
      end

      [status, headers, body]
    end

    def set_view_path(path)
      @root = path
    end

    class File < ::Rack::File
      def _call(env)
        @path_info = Utils.unescape(env["PATH_INFO"])
        return forbidden  if @path_info.include? ".."
        
        @path = ::File.join(@root, @path_info)
        
        begin
          if ::File.file?(@path) && ::File.readable?(@path)
            serving
          else
            if path_modified_servable?
              serving
            else
              raise Errno::EPERM
            end
          end
        rescue SystemCallError
          not_found
        end
      end

      def path_modified_servable?
        path_trailing_slash_servable? || path_dir_no_slash_servable? || path_with_ext_servable? || false
      end

      def path_trailing_slash_servable?
        if @path =~ /\/$/
          path_with_index_file = @path + 'index.html'
          if ::File.file?(path_with_index_file) && ::File::readable?(path_with_index_file)
            @path = path_with_index_file
            return true
          end
        end

        return false
      end

      def path_dir_no_slash_servable?
        if @path !~ /\/$/ && @path !~ /\.\w+$/
          path_with_index_file = @path + '/index.html'
          if ::File.file?(path_with_index_file) && ::File::readable?(path_with_index_file)
            @path = path_with_index_file
            return true
          end
        end

        return false
      end

      def path_with_ext_servable?
        if @path !~ /\/$/ && @path !~ /\.\w+$/
          path_with_ext = @path + '.html'
          if ::File.file?(path_with_ext) && ::File::readable?(path_with_ext)
            @path = path_with_ext
            return true
          end
        end

        return false
      end
    end
  end
end
