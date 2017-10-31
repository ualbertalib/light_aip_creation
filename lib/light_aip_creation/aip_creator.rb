require 'light_aip_creation/version'
require 'minitar'
require 'bagit'
require 'fileutils'

class LightAipCreation::AipCreator
  class BagInvalid < StandardError; end

  def initialize(workdir, noid = '')
    @work_dir = File.expand_path(workdir)
    @aip_directory="#{@work_dir}/#{noid}"
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
    tar_aip_filename = "#{@work_dir}/#{File.basename(@aip_directory)}.tar"

    Dir.chdir(@work_dir)
    Minitar.pack(@aip_directory, File.open(tar_aip_filename, 'wb'))
    tar_aip_filename
  end

  def assemble_aip(options)
    validate_files
    make_aip_dirs
    copy_aip_files
    rm_aip_dir
  end

  ### AIP Directories
  def aip_dirs
      @aip_dirs = [
        "#{@aip_directory}/data/objects",
        "#{@aip_directory}/data/objects/metadata",
        "#{@aip_directory}/data/logs",
        "#{@aip_directory}/data/thumbnails"
      ]
  end

  def make_aip_dirs
    aip_dirs.each { |path| FileUtils.mkdir_p(path) }
  end

  def rm_aip_dir
    return unless File.exist?(@aip_directory)
    FileUtils.rm_rf(@aip_directory)
  end

  ### AIP Files
  def aip_files
    @aip_files = [
      # required files
      # object_metadata
      {
        remote: @options[:object_metadata],
        local: "#{aip_dirs.metadata}/object_metadata.n3",
        required: true
      },
      # fixity
      {
        remote: @options[:fixity],
        local: "#{aip_dirs.logs}/content_fixity_report.n3",
        required: true
      },
      #content_datastream_metadata
      {
        remote: @options[:content_meta],
        local: "#{aip_dirs.metadata}/content_fcr_metadata.n3",
        required: true
      },
      #versions
      {
        remote: @options[:versions],
        local: "#{aip_dirs.metadata}/content_versions.n3",
        required: true
      },
      # optional files
      # thumbnail
      {
        remote: @options[:thumbnail],
        local: "#{aip_dirs.thumbnails}/thumbnail",
        required: false
      },
      #characterization
      {
        remote: @options[:characterization],
        local: "#{aip_dirs.logs}/content_characterization.n3",
        required: false
      }
    ]

    @options[:content]&.each do | value |
        @aip_files.push(
          remote: value,
          local: "#{@aip_directory}/#{File.basename(@options[value])}",
          required: true
        )
    end

    @options[:permissions]&.each do | value |
        @aip_files.push(
          remote: value,
          local: "#{aip_dirs.metadata}/#{File.basename(value)}",
          required: false
        )
    end
  end

  def copy_aip_files
    @aip_files.each { |file| FileUtils.cp(file[:remote], file[:local]) unless file[:remote].nil? }
  end

  def validate_files
      @aip_files.each { |file| raise "missing file #{file[:remote]}" if file[:required] && file[:remot].nil? }
  end
end
