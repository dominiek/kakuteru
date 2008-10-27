class Asset < ActiveRecord::Base
  belongs_to :post
  
  def self.upload(file, options = {})
    original_filename = file.respond_to?(:original_filename) ? file.original_filename : Time.now.to_i.to_s
    original_filename.gsub!(/\//, '_')
    file = ensure_temp_file(file)
    now = Time.now
    relative_destination_path = File.join(now.strftime("%Y"), now.strftime("%m").to_i.to_s, now.strftime("%d").to_i.to_s, original_filename)
    absolute_destination_path = File.join(RAILS_ROOT, 'public', 'assets', relative_destination_path)
    FileUtils.mkdir_p(File.dirname(absolute_destination_path))
    FileUtils.cp(file.path, absolute_destination_path)
    asset = self.find_or_create_by_path(relative_destination_path)
    asset.update_attributes(:post_id => options[:post_id])
    asset
  end
  
  private
  
  def self.ensure_temp_file(data)
    # Rails for some reason converts data less than a certain size to StringIO
    # which is incompatible with ImageScience's stupid notion that it only deals with paths
    # http://blog.vixiom.com/2006/07/26/rails-stringio-file-upload/
    if data.kind_of?(StringIO) || data.kind_of?(ActionController::UploadedStringIO)
      string = data.read
      file = Tempfile.new(Time.now.to_f.to_s)
      file.print(string)
      file.close
      file.open
    elsif data.kind_of?(Tempfile) || data.kind_of?(File)
      file = data
    else
      raise 'Invalid File Format'
    end
    file
  end
end
