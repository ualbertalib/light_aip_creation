require 'light_aip_creation/version'
require 'minitar'
require 'bagit'
require 'fileutils'

class LightAipCreation::AipCreator
  class BagInvalid < StandardError; end

  def initialize(noid, workdir)
    @noid = noid
    @work_dir = workdir
    @aip_directory="#{@work_dir}/#{@noid}"
  end

  def bag_tar_aip_dir(aip_directory)
    @aip_directory=aip_directory unless aip_directory.nil?
    bag_aip
    tar_bag
  end

  def create_aip(options = {})
      assemble_aip(options)
      bag_tar_aip_dir()
  end

  def bag_aip
    bag = BagIt::Bag.new(@aip_directory)
    bag.manifest!
    raise BagInvalid unless bag.valid?
  end

  def tar_bag
    aip_filename = "#{@aip_directory}.tar"
    tar_aip_filename = File.expand_path(aip_filename)

    Dir.chdir(@work_dir) do
      Minitar.pack(@noid, File.open(tar_aip_filename, 'wb'))
    end
  end

  def assemble_aip(options)

    make_aip_dirs
    copy_aip_files
    rm_aip_dir
  end

  ### AIP Directories
  def aip_dirs
      @aip_dirs = {
        objects: "#{@aip_directory}/data/objects",
        metadata: "#{@aip_directory}/data/objects/metadata",
        logs: "#{@aip_directory}/data/logs",
        thumbnails: "#{@aip_directory}/data/thumbnails"
      }
  end

  def make_aip_dirs
    aip_dirs.each_value do |path|
      FileUtils.mkdir_p(path)
    end
  end

  def rm_aip_dir
    return unless File.exist?(@aip_directory)
    FileUtils.rm_rf(@aip_directory)
  end

  ### AIP Files
  def aip_paths
    @aip_paths = {
      # required files
      content: {
        remote: @options[:contnet],
        local: "#{@aip_directory}/#{File.basename(@options[:contnet])}",
        optional: false
      },
      object_metadata: {
        remote: @options[:object_metadata],
        local: "#{aip_dirs.metadata}/object_metadata.n3",
        optional: false
      },
      fixity: {
        remote: @options[:fixity],
        local: "#{aip_dirs.logs}/content_fixity_report.n3",
        optional: false
      },
      content_datastream_metadata: {
        remote: @options[:content_meta],
        local: "#{aip_dirs.metadata}/content_fcr_metadata.n3",
        optional: false
      },
      versions: {
        remote: @options[:versions],
        local: "#{aip_dirs.metadata}/content_versions.n3",
        optional: false
      },
      # optional files
      thumbnail: {
        remote: @options[:thumbnail],
        local: "#{aip_dirs.thumbnails}/thumbnail",
        optional: true
      },
      characterization: {
        remote: @options[:characterization],
        local: "#{aip_dirs.logs}/content_characterization.n3",
        optional: true
      }
    }
    @options[:permissions]&.each do |key, value|
      @aip_paths[:key] = {
        remote: value,
        local: "#{aip_dirs.metadata}/#{File.basename(value)}",
        optional: true
      }
    end
  end

  def  copy_aip_files
    @aip_paths.each_value do |file|
      if !file[:optional]
        FileUtils.cp(file[:remote], file[:local])
      else
        FileUtils.cp(file[:remote], file[:local]) unless file[:remote].nil?
      end
    end
  end

end
