#
# rexif_gps.rb
#  -- exif parser library (with GPS)
#
# kp <k-nomura@s6.dion.ne.jp>
# 
# オリジナルからの変更点
#  ・InterOperabilityIFD対応削除
#  ・GPS IFDへの対応
#  ・Rational.new→Rational.new!
#

require 'rational'
require 'rjpeg'

class Exif<Jpeg::Segment
    class ParseError<Jpeg::ParseError
    end

    #
    # Data with read class 
    #
    class Data
	PACKSTR={
	    :le=>{
		:ushort=>'v*',
		:ulong=>'V*',
		:float=>'e*',
		:double=>'E*'
	    }.freeze,
	    :be=>{
		:ushort=>'n*',
		:ulong=>'N*',
		:float=>'g*',
		:double=>'G*'
	    }.freeze
	}
	PACKSTR.freeze

	def initialize(data,endian=:le)
	    @data=data
	    @endian=endian
	end
	attr_reader :endian

	def get_ushort(offset=0)
	    self.read_ushort(offset,1).first
	end
	def get_ulong(offset=0)
	    self.read_ulong(offset,1).first
	end
	
	def read_char(offset=0,n=1)
	    @data[offset..offset+n-1]
	end
	def read_ascii(offset=0,n=1)
	    @data[offset..offset+n-1].unpack('A*')
	end
	def read_byte(offset=0,n=1)
	    @data[offset..offset+n-1].unpack('c*')
	end
	def read_ubyte(offset=0,n=1)
	    @data[offset..offset+n-1].unpack('C*')
	end
	def read_short(offset=0,n=1)
	    self.read_ushort(offset,n).pack('s*').unpack('s*')
	end
	def read_long(offset=0,n=1)
	    self.read_ulong(offset,n).pack('l*').unpack('l*')
	end
	def read_rational(offset=0,n=1)
	    ret=[]
	    buf=self.read_long(offset,n*2)
	    until(buf.empty?)
		ret.push(Exif::Rational.new!(buf.shift,buf.shift))
	    end
	    ret
	end
	def read_urational(offset=0,n=1)
	    ret=[]
	    buf=self.read_ulong(offset,n*2)
	    until(buf.empty?)
		ret.push(Exif::Rational.new!(buf.shift,buf.shift))
	    end
	    ret
	end

	def read_ushort(offset=0,n=1)
	    @data[offset..offset+n*2-1].unpack(PACKSTR[@endian][:ushort])
	end
	def read_ulong(offset=0,n=1)
	    @data[offset..offset+n*4-1].unpack(PACKSTR[@endian][:ulong])
	end
	def read_float(offset=0,n=1)
	    @data[offset..offset+n*4-1].unpack(PACKSTR[@endian][:float])
	end
	def read_double(offset=0,n=1)
	    @data[offset..offset+n*8-1].unpack(PACKSTR[@endian][:double])
	end

	def to_s
	    @data
	end
	alias dump to_s

	def size
	    @data.size
	end

	def Data.new_char(x,endian=:le)
	    Data.new(x.to_s,endian)
	end
	def Data.new_ascii(x,endian=:le)
	    Data.new(x.to_a.pack('A*')+"\x00",endian)
	end
	def Data.new_byte(x,endian=:le)
	    Data.new(x.to_a.pack('c*'),endian)
	end
	def Data.new_ubyte(x,endian=:le)
	    Data.new(x.to_a.pack('C*'),endian)
	end
	def Data.new_short(x,endian=:le)
	    Data.new(x.to_a.pack('s*').
		     unpack(PACKSTR[endian][:ushort]).
		     pack(PACKSTR[endian][:ushort]),
		     endian)
	end
	def Data.new_ushort(x,endian=:le)
	    Data.new(x.to_a.pack(PACKSTR[endian][:ushort]),
		     endian)
	end
	def Data.new_long(x,endian=:le)
	    Data.new(x.to_a.pack('l*').
		     unpack(PACKSTR[endian][:ulong]).
		     pack(PACKSTR[endian][:ulong]),
		     endian)
	end
	def Data.new_ulong(x,endian=:le)
	    Data.new(x.to_a.pack(PACKSTR[endian][:ulong]),endian)
	end
	def Data.new_rational(x,endian=:le)
	    Data.new_long(x.to_a.map{|a| a.to_a}.flatten,
			  endian)
	end
	def Data.new_urational(x,endian=:le)
	    Data.new_ulong(x.to_a.map{|a| a.to_a}.flatten,
			   endian)
	end
	def Data.new_float(x,endian=:le)
	    Data.new(x.to_a.pack(PACKSTR[endian][:float]),endian)
	end
	def Data.new_double(x,endian=:le)
	    Data.new(x.to_a.pack(PACKSTR[endian][:double]),endian)
	end
    end

    class Rational<Rational
	def to_a
	    [@numerator,@denominator]
	end
    end

    #
    # Exif::Ifd
    #
    class Ifd<Array

	#
	# Exif::Ifd::Directory
	#
	class Directory
	    #
	    # Tag Names
	    #
#	    InteroperabilityIndex=0x0001
#	    InteroperabilityVersion=0x0002

# gps tags
# added by kp

		VersionID=0x0000
		LatitudeRef=0x0001
		Latitude=0x0002
		LongitudeRef=0x0003
		Longitude=0x0004
		AltitudeRef=0x0005
		Altitude=0x0006
		TimeStamp=0x0007
		Satellites=0x0008
		Status=0x0009
		MeasureMode=0x000a
		Dop=0x000b
		SpeedRef=0x000c
		Speed=0x000d
		TrackRef=0x000e
		Track=0x000f
		ImgDirectionRef=0x0010
		ImgDirection=0x0011
		MapDatum=0x0012
		DestLatitudeRef=0x0013
		DestLatitude=0x0014
		DestLongitudeRef=0x0015
		DestLongitude=0x0016
		DestBearingRef=0x0017
		DestBearing=0x0018
		DestDistanceRef=0x0019
		DestDistance=0x001a
		ProcessingMethod=0x001b
		AreaInformation=0x001c
		DataStamp=0x001d
		Differential=0x001e
		
	    NewSubfileType=0x00fe
	    SubfileType=0x00ff
	    ImageWidth=0x0100
	    ImageLength=0x0101
	    BitsPerSample=0x0102
	    Compression=0x0103
	    PhotometricInterpretation=0x0106
	    ImageDescription=0x010e
	    Maker=0x010f
	    Model=0x0110
	    StripOffsets=0x0111
	    Orientation=0x0112
	    SamplesPerPixel=0x0115
	    RowsPerStrip=0x0116
	    StripByteConunts=0x0117
	    XResolution=0x011a
	    YResolution=0x011b
	    PlanarConfiguration=0x011c
	    ResolutionUnit=0x0128
	    TransferFunction=0x012d
	    Software=0x0131
	    DateTime=0x0132
	    Artist=0x013b
	    Predictor=0x013d
	    WhitePoint=0x013e
	    PrimaryChromaticities=0x013f
	    TileWidth=0x0142
	    TileLength=0x0143
	    TileOffsets=0x0144
	    TileByteCounts=0x0145
	    SubIFDs=0x014a
	    JPEGTables=0x015b
	    JpegInterchangeFormat=0x0201
	    JpegInterchangeFormatLength=0x0202
	    YCbCrCoefficients=0x0211
	    YCbCrSubSampling=0x0212
	    YCbCrPositioning=0x0213
	    ReferenceBlackWhite=0x0214
	    RelatedImageFileFormat=0x1000
	    RelatedImageWidth=0x1001
	    CFARepeatPatternDim=0x828d
	    CFAPattern=0x828e
	    BatteryLevel=0x828f
	    Copyright=0x8298
	    ExposureTime=0x829a
	    FNumber=0x829d
	    IPTC_NAA=0x83bb
	    ExifIFDPointer=0x8769
	    InterColorProfile=0x8773
	    ExposureProgram=0x8822
	    SpectralSensitivity=0x8824
	    GPSIFDPointer=0x8825		#GPSInfo -> GPSIFDPointer
	    ISOSpeedRatings=0x8827
	    OECF=0x8828
	    Interlace=0x8829
	    TimeZoneOffset=0x882a
	    SelfTimerMode=0x882b
	    ExifVersion=0x9000
	    DateTimeOriginal=0x9003
	    DateTimeDigitized=0x9004
	    ComponentsConfiguration=0x9101
	    CompressedBitsPerPixel=0x9102
	    ShutterSpeedValue=0x9201
	    ApertureValue=0x9202
	    BrightnessValue=0x9203
	    ExposureBiasValue=0x9204
	    MaxApertureValue=0x9205
	    SubjectDistance=0x9206
	    MeteringMode=0x9207
	    LightSource=0x9208
	    Flash=0x9209
	    FocalLength=0x920a
	    FlashEnergy=0x920b
	    SpatialFrequencyResponse=0x920c
	    Noise=0x920d
	    ImageNumber=0x9211
	    SecurityClassification=0x9212
	    ImageHistory=0x9213
	    SubjectLocation=0x9214
	    ExposureIndex=0x9215
	    TIFF_EPStandardID=0x9216
	    MakerNote=0x927c
	    UserComment=0x9286
	    SubSecTime=0x9290
	    SubSecTimeOriginal=0x9291
	    SubSecTimeDigitized=0x9292
	    FlashPixVersion=0xa000
	    ColorSpace=0xa001
	    ExifImageWidth=0xa002
	    ExifImageHeight=0xa003
	    RelatedSoundFile=0xa004
	    InteroperabilityIFDPointer=0xa005
	    FlashEnergy2=0xa20b
	    SpatialFrequencyResponse2=0xa20c
	    FocalPlaneXResolution=0xa20e
	    FocalPlaneYResolution=0xa20f
	    FocalPlaneResolutionUnit=0xa210
	    SubjectLocation2=0xa214
	    ExposureIndex2=0xa215
	    SensingMethod=0xa217
	    FileSource=0xa300
	    SceneType=0xa301
	    CFAPattern2=0xa302
	    
	    class TagInfo
		def initialize(name,format,limit=0)
		    @name=name
		    @format=format.to_a.freeze
		    @limit=limit
		end
		attr_reader :name,:format,:limit
	    end

	    TAG_NAME={
#		0x0001=>TagInfo.new("InteroperabilityIndex",[2],0),
#		0x0002=>TagInfo.new("InteroperabilityVersion",[7],4),

		0x0000=>TagInfo.new("VersionID",[1],4),
		0x0001=>TagInfo.new("LatitudeRef",[2],2),
		0x0002=>TagInfo.new("Latitude",[5],3),
		0x0003=>TagInfo.new("LongitudeRef",[2],2),
		0x0004=>TagInfo.new("Longitude",[5],3),
		0x0005=>TagInfo.new("AltitudeRef",[1],1),
		0x0006=>TagInfo.new("Altitude",[5],1),
		0x0007=>TagInfo.new("TimeStamp",[5],3),
		0x0008=>TagInfo.new("Satellites",[1],0),
		0x0009=>TagInfo.new("Status",[2],2),
		0x000a=>TagInfo.new("MeasureMode",[2],2),
		0x000b=>TagInfo.new("Dop",[5],1),
		0x000c=>TagInfo.new("SpeedRef",[2],2),
		0x000d=>TagInfo.new("Speed",[5],1),
		0x000e=>TagInfo.new("TrackRef",[2],2),
		0x000f=>TagInfo.new("Track",[5],1),
		0x0010=>TagInfo.new("ImgDirectionRef",[2],2),
		0x0011=>TagInfo.new("ImgDirection",[5],1),
		0x0012=>TagInfo.new("MapDatum",[2],0),
		0x0013=>TagInfo.new("DestLatitudeRef",[2],2),
		0x0014=>TagInfo.new("DestLatitude",[5],3),
		0x0015=>TagInfo.new("DestLongitudeRef",[2],2),
		0x0016=>TagInfo.new("DestLongitude",[5],3),
		0x0017=>TagInfo.new("DestBearingRef",[2],2),
		0x0018=>TagInfo.new("DestBearing",[5],1),
		0x0019=>TagInfo.new("DestDistanceRef",[2],2),
		0x001a=>TagInfo.new("DestDistance",[5],1),
		0x001b=>TagInfo.new("ProcessingMethod",[7],0),
		0x001c=>TagInfo.new("AreaInformation",[7],0),
		0x001d=>TagInfo.new("DataStamp",[2],11),
		0x001e=>TagInfo.new("Differential",[3],1),

		0x00fe=>TagInfo.new("NewSubfileType",[4],1),
		0x00ff=>TagInfo.new("SubfileType",[3],1),
		0x0100=>TagInfo.new("ImageWidth",[3,9],1),
		0x0101=>TagInfo.new("ImageLength",[3,9],1),
		0x0102=>TagInfo.new("BitsPerSample",[3],3),
		0x0103=>TagInfo.new("Compression",[3],1),
		0x0106=>TagInfo.new("PhotometricInterpretation",[3],1),
		0x010e=>TagInfo.new("ImageDescription",[2],0),
		0x010f=>TagInfo.new("Maker",[2],0),
		0x0110=>TagInfo.new("Model",[2],0),
		0x0111=>TagInfo.new("StripOffsets",[3,9],0),
		0x0112=>TagInfo.new("Orientation",[3],1),
		0x0115=>TagInfo.new("SamplesPerPixel",[3],1),
		0x0116=>TagInfo.new("RowsPerStrip",[3,9],1),
		0x0117=>TagInfo.new("StripByteConunts",[3,9],0),
		0x011a=>TagInfo.new("XResolution",[5],1),
		0x011b=>TagInfo.new("YResolution",[5],1),
		0x011c=>TagInfo.new("PlanarConfiguration",[3],1),
		0x0128=>TagInfo.new("ResolutionUnit",[3],1),
		0x012d=>TagInfo.new("TransferFunction",[3],3),
		0x0131=>TagInfo.new("Software",[2],0),
		0x0132=>TagInfo.new("DateTime",[2],20),
		0x013b=>TagInfo.new("Artist",[2],0),
		0x013d=>TagInfo.new("Predictor",[3],1),
		0x013e=>TagInfo.new("WhitePoint",[5],2),
		0x013f=>TagInfo.new("PrimaryChromaticities",[5],6),
		0x0142=>TagInfo.new("TileWidth",[3],1),
		0x0143=>TagInfo.new("TileLength",[3],1),
		0x0144=>TagInfo.new("TileOffsets",[4],0),
		0x0145=>TagInfo.new("TileByteCounts",[3],0),
		0x014a=>TagInfo.new("SubIFDs",[4],0),
		0x015b=>TagInfo.new("JPEGTables",[7],0),
		0x0201=>TagInfo.new("JpegInterchangeFormat",[4],1),
		0x0202=>TagInfo.new("JpegInterchangeFormatLength",[4],1),
		0x0211=>TagInfo.new("YCbCrCoefficients",[5],3),
		0x0212=>TagInfo.new("YCbCrSubSampling",[3],2),
		0x0213=>TagInfo.new("YCbCrPositioning",[3],1),
		0x0214=>TagInfo.new("ReferenceBlackWhite",[5],6),
		0x1000=>TagInfo.new("RelatedImageFileFormat",[2],0),
		0x1001=>TagInfo.new("RelatedImageLength",[8],0),
		0x1001=>TagInfo.new("RelatedImageWidth",[8],0),
		0x828d=>TagInfo.new("CFARepeatPatternDim",[3],2),
		0x828e=>TagInfo.new("CFAPattern",[1],0),
		0x828f=>TagInfo.new("BatteryLevel",[5],1),
		0x8298=>TagInfo.new("Copyright",[2],0),
		0x829a=>TagInfo.new("ExposureTime",[5],1),
		0x829d=>TagInfo.new("FNumber",[5],1),
		0x83bb=>TagInfo.new("IPTC_NAA",[4],0),
		0x8769=>TagInfo.new("ExifIFDPointer",[4],1),
		0x8773=>TagInfo.new("InterColorProfile",[7],0),
		0x8822=>TagInfo.new("ExposureProgram",[3],1),
		0x8824=>TagInfo.new("SpectralSensitivity",[2],0),
		0x8825=>TagInfo.new("GPSIFDPointer",[4],1),
		0x8827=>TagInfo.new("ISOSpeedRatings",[3],2),
		0x8828=>TagInfo.new("OECF",[7],0),
		0x8829=>TagInfo.new("Interlace",[3],1),
		0x882a=>TagInfo.new("TimeZoneOffset",[8],1),
		0x882b=>TagInfo.new("SelfTimerMode",[3],1),
		0x9000=>TagInfo.new("ExifVersion",[7],4),
		0x9003=>TagInfo.new("DateTimeOriginal",[2],20),
		0x9004=>TagInfo.new("DateTimeDigitized",[2],20),
		0x9101=>TagInfo.new("ComponentsConfiguration",[7],4),
		0x9102=>TagInfo.new("CompressedBitsPerPixel",[5],1),
		0x9201=>TagInfo.new("ShutterSpeedValue",[10],1),
		0x9202=>TagInfo.new("ApertureValue",[5],1),
		0x9203=>TagInfo.new("BrightnessValue",[10],1),
		0x9204=>TagInfo.new("ExposureBiasValue",[10],1),
		0x9205=>TagInfo.new("MaxApertureValue",[5],1),
		0x9206=>TagInfo.new("SubjectDistance",[10],1),
		0x9207=>TagInfo.new("MeteringMode",[3],1),
		0x9208=>TagInfo.new("LightSource",[3],1),
		0x9209=>TagInfo.new("Flash",[3],1),
		0x920a=>TagInfo.new("FocalLength",[5],1),
		0x920b=>TagInfo.new("FlashEnergy",[5],1),
		0x920c=>TagInfo.new("SpatialFrequencyResponse",[7],0),
		0x920d=>TagInfo.new("Noise",[7],0),
		0x9211=>TagInfo.new("ImageNumber",[4],1),
		0x9212=>TagInfo.new("SecurityClassification",[2],1),
		0x9213=>TagInfo.new("ImageHistory",[2],0),
		0x9214=>TagInfo.new("SubjectLocation",[3],4),
		0x9215=>TagInfo.new("ExposureIndex",[5],1),
		0x9216=>TagInfo.new("TIFF_EPStandardID",[1],4),
		0x927c=>TagInfo.new("MakerNote",[7],0),
		0x9286=>TagInfo.new("UserComment",[7],0),
		0x9290=>TagInfo.new("SubSecTime",[2],0),
		0x9290=>TagInfo.new("SubsecTime",[2],0),
		0x9291=>TagInfo.new("SubSecTimeOriginal",[2],0),
		0x9291=>TagInfo.new("SubsecTimeOriginal",[2],0),
		0x9292=>TagInfo.new("SubSecTimeDigitized",[2],0),
		0x9292=>TagInfo.new("SubsecTimeDigitized",[2],0),
		0xa000=>TagInfo.new("FlashPixVersion",[7],4),
		0xa001=>TagInfo.new("ColorSpace",[3],1),
		0xa002=>TagInfo.new("ExifImageWidth",[3,9],1),
		0xa003=>TagInfo.new("ExifImageHeight",[3,9],1),
		0xa004=>TagInfo.new("RelatedSoundFile",[2],0),
		0xa005=>TagInfo.new("InteroperabilityIFDPointer",[4],1),
		0xa20b=>TagInfo.new("FlashEnergy",[5],1),
		0xa20c=>TagInfo.new("SpatialFrequencyResponse",[3],1),
		0xa20e=>TagInfo.new("FocalPlaneXResolution",[5],1),
		0xa20f=>TagInfo.new("FocalPlaneYResolution",[5],1),
		0xa210=>TagInfo.new("FocalPlaneResolutionUnit",[3],1),
		0xa214=>TagInfo.new("SubjectLocation",[3],1),
		0xa215=>TagInfo.new("ExposureIndex",[5],1),
		0xa217=>TagInfo.new("SensingMethod",[3],1),
		0xa300=>TagInfo.new("FileSource",[7],1),
		0xa301=>TagInfo.new("SceneType",[7],1),
		0xa302=>TagInfo.new("CFAPattern",[7],0)
	    }
	    TAG_NAME.freeze
	    
	    DIRENT_SIZE=12  # tag(2bytes)+format(2bytes)+
	                    #    data_num(4bytes)+data(4bytes)

	    FORMAT_NAME=[nil,
		'ubyte',
		'ascii',
		'ushort',
		'ulong',
		'urational',
		'byte',
		'undefined',
		'short',
		'long',
		'rational',
		'float',
		'double']
	    FORMAT_NAME.freeze

	    FORMAT_SIZE=[nil,
		1,1,2,4,8,1,
		1,2,4,8,4,8]
	    FORMAT_SIZE.freeze
	    
	    READ_PROC=[nil,
		proc{|x,o,n| x.read_ubyte(o,n)},
		proc{|x,o,n| x.read_ascii(o,n)},
		proc{|x,o,n| x.read_ushort(o,n)},
		proc{|x,o,n| x.read_ulong(o,n)},
		proc{|x,o,n| x.read_urational(o,n)},
		proc{|x,o,n| x.read_byte(o,n)},
		proc{|x,o,n| x.read_char(o,n)},
		proc{|x,o,n| x.read_short(o,n)},
		proc{|x,o,n| x.read_long(o,n)},
		proc{|x,o,n| x.read_rational(o,n)},
		proc{|x,o,n| x.read_float(o,n)},
		proc{|x,o,n| x.read_double(o,n)}
	    ]
	    READ_PROC.freeze

	    PACK_PROC=[nil,
		proc{|x,e| Data.new_ubyte(x,e).to_s},
		proc{|x,e| Data.new_ascii(x,e).to_s},
		proc{|x,e| Data.new_ushort(x,e).to_s},
		proc{|x,e| Data.new_ulong(x,e).to_s},
		proc{|x,e| Data.new_urational(x,e).to_s},
		proc{|x,e| Data.new_byte(x,e).to_s},
		proc{|x,e| Data.new_char(x,e).to_s},
		proc{|x,e| Data.new_short(x,e).to_s},
		proc{|x,e| Data.new_long(x,e).to_s},
		proc{|x,e| Data.new_rational(x,e).to_s},
		proc{|x,e| Data.new_float(x,e).to_s},
		proc{|x,e| Data.new_double(x,e).to_s}
	    ]
	    PACK_PROC.freeze

	    TIME_PARSE_PROC=proc{|x|
		if(x=~/(\d{4}):(\d\d):(\d\d) (\d\d):(\d\d):(\d\d)/)
		    Time.mktime($1.to_i,$2.to_i,$3.to_i,
				$4.to_i,$5.to_i,$6.to_i)
		else
		    x
		end
	    }

	    @@value_parse_proc={}

	    #
	    # Exif::Ifd::Directory
	    #
	    def initialize(ifd_name='',x=nil,offset=0)
		@tag=nil    # 2bytes
		@format=nil # data format
		#data_num   # Number of data
		@value=[]   # data

		@is_ifd=false

		@ifd_name=ifd_name
		@endian=:le

		unless(x.nil?)
		    parse(x,offset)
		end
	    end
	    attr_reader :tag,:format
	    
	    def tag_name
		n=TAG_NAME[@tag]
		if(n.nil?)
		    "#{@ifd_name}.#{sprintf('0x%04x',@tag)}"
		else
		    "#{@ifd_name}.#{n.name}"
		end
	    end
	    def format_name
		FORMAT_NAME[@format]
	    end

	    def parse(x,offset=0)
		begin
		    @tag=x.get_ushort(offset)
		    offset+=2
		    @format=x.get_ushort(offset)
		    offset+=2
		    data_num=x.get_ulong(offset)
		    offset+=4
		rescue NameError, TypeError
		    raise Exif::ParseError,
			"Invalid offset (#{sprintf("0x%04x",offset)}) "+
			"given for #{self.tag_name}."
		end

		begin
		    if(data_num*FORMAT_SIZE[@format]>4)
			offset=x.get_ulong(offset)
		    end
		rescue NameError, TypeError
		    raise Exif::ParseError,
			"Invalid format (#{@format}) "+
			"found at #{self.tag_name} "+
			"(offset: #{sprintf("0x%04x",offset)})"
		end

		@value=READ_PROC[@format].call(x,offset,data_num)

		case @format
		when 2
		    begin
			@value=@value.first
		    rescue NameError
		    end
		when 7
		    @value=Data.new(@value,x.endian)
		else
		    begin
			if(TAG_NAME[@tag].limit==1)
			    @value=@value.first
			end
		    rescue NameError
		    end
		end
	    end

	    def value
		proc=@@value_parse_proc[@tag]
		if(@@value_parse_proc.has_key?(@tag))
		    @@value_parse_proc[@tag].call(@value)
		else
		    @value
		end
	    end
	    
	    def value=(x)
		_size_check(x)
		@format=_format_check(x)
		if(x.kind_of?(Ifd))
		    @is_ifd=true
		else
		    @is_ifd=false
		end
		@value=x
	    end
	    
	    def is_ifd?
		@is_ifd
	    end

	    def is_array?
		(!@is_ifd)&&@value.kind_of?(Array)
	    end

	    def to_a
		@value.to_a
	    end

	    def to_i
		begin
		    @value.to_i
		rescue NameError
		    0
		end
	    end

	    def to_f
		begin
		    @value.to_f
		rescue NameError
		    0.0
		end
	    end

	    def to_s
		@value.to_s
	    end

	    def to_time
		t=TIME_PARSE_PROC.call(@value)
		if(t.kind_of?(Time))
		    t
		else
		    Time.at(0)
		end
	    end

	    def data_num
		if(@value.kind_of?(Array)&&!@value.kind_of?(Ifd))
		    @value.size
		elsif(@format==2)
		    @value.size+1
		elsif(@format==7)
		    @value.size
		else
		    1
		end
	    end

	    def data_size
		if(@is_ifd)
		    @value.byte_size
		else
		    self.data_num*FORMAT_SIZE[@format]
		end
	    end
	    
	    def byte_size
		s=self.data_size
		if(s<=4)
		    DIRENT_SIZE
		else
		    DIRENT_SIZE+s
		end
	    end

	    def dump_head(offset=0,endian=:le)
		if(self.data_size>4)
		    Data.new_ushort(@tag,endian).to_s+
			Data.new_ushort(@format,endian).to_s+
			Data.new_ulong(self.data_num,endian).to_s+
			Data.new_ulong(offset,endian).to_s
		else
		    data=self.dump_data(offset,endian,true)
		    Data.new_ushort(@tag,endian).to_s+
			Data.new_ushort(@format,endian).to_s+
			Data.new_ulong(self.data_num,endian).to_s+
			data+"\x00"*(4-data.size)
		end
	    end
	    
	    def dump_data(offset=0,endian=:le,force_dump=false)
		if(force_dump||self.data_size>4)
		    data=@value
		    if(@is_ifd)
			data=data.dump(offset,endian,false)
		    else
			if(data.kind_of?(Data))
			    data=data.to_s
			end
			data=PACK_PROC[@format].call(data,endian)
		    end
		else
		    nil
		end
	    end
	    
	    def dump(offset=0,endian=:le)
		[self.dump_head(offset,endian),
		    self.dump_data(offset,endian)]
	    end
	    
	    def Directory.use_proc_for(tag,proc)
		@@value_parse_proc[tag]=proc
	    end

	    private
	    def _size_check(x)
		s=1
		if((x.kind_of?(Array)&&!x.kind_of?(Ifd))||
		    x.kind_of?(String))
		    s=x.size
		end
		if(TAG_NAME.has_key?(@tag))
		    if(TAG_NAME[@tag].limit>0&&TAG_NAME[@tag].limit<s)
			raise TypeError,
			    "#{self.tag_name} value size is limited to #{TAG_NAME[@tag].limit}."
		    end
		end
	    end

	    def _format_check(x)
		format=_guess_format_type(x)
		if(format.member?(@format))
		    return @format
		end
		if(TAG_NAME.has_key?(@tag))
		    format.each{|f|
			if(TAG_NAME[@tag].format.member?(f))
			    return f
			end
		    }
		    f=TAG_NAME[@tag].format.map{|x|
			FORMAT_NAME[x]
		    }.join('|')
		    raise TypeError,
			"#{self.tag_name} requires #{f} value."
		else
		    format.first
		end
	    end
	    
	    def _guess_format_type(x)
		if(x.kind_of?(Ifd))
		    [7,4]
		else
		    if(x.kind_of?(Array))
			x=x.first
		    end
		    if(x.kind_of?(String))
			[2,1,3,4,5,6,8,9,10,11,12,7]
		    elsif(x.kind_of?(Integer))
			if(x<0)
			    if(x<-32768)
				[9,7]
			    elsif(x<-128)
				[8,9,7]
			    else
				[6,8,9,7]
			    end
			else
			    if(x>32767)
				[4,9,7]
			    elsif(x>127)
				[3,4,7,8,9]
			    else
				[1,3,4,6,7,8,9]
			    end
			end
		    elsif(x.kind_of?(Rational))
			if(x.numerator>32767||x.denominator>32767)
			    [5,7]
			else
			    [10,5,7]
			end
		    elsif(x.kind_of?(Float))
			[12,11,7]
		    else
			[7]
		    end
		end
	    end
	    
	end
	
	IFD0='IFD0'
	ImageIFD='IFD0'
	IFD1='IFD1'
	ThumnailIFD='IFD1'
	ExifIFD='IFD0.ExifIFD'
#	InteroperabilityIFD='IFD0.ExifIFD.InteroperabilityIFD'
	GPSIFD='IFD0.ExifIFD.GPSIFD'
	
	#
	# Exif::Ifd < Array
	#
	def initialize(ifd_name='',x=nil,offset=0,&block)
	    super()

	    # dirnum=0   # Number of Directory Entry (2bytes)
	    # dirs=[]    # Directory Entries (12 * dirnum bytes)
	    # next_ifd=0 # Offset to next ifd (4bytes)

	    @ifd_name=ifd_name
	    @thumbnail=nil
	    unless(x.nil?)
		parse(x,offset,&block)
	    end
	end
	attr_reader :ifd_name

	def parse(x,offset=0,&block)
	    begin
		n=x.get_ushort(offset)
	    rescue NameError,TypeError
		raise Exif::ParseError,
		    "Invalid offset (#{sprintf("0x%04x",offset)}) "+
		    "given for #{@ifd_name}."
	    end
	    offset+=2

	    n.times{|i|
		d=Directory.new(@ifd_name,x,offset)

		if(block.nil?)
		    self.push(d)
		else
		    self.push(yield(d))
		end
		offset+=Directory::DIRENT_SIZE

		#
		# create method to access directory
		#
		n=sprintf('x%04x',d.tag)
		self.instance_eval("def #{n};self[#{self.size-1}];end")
		n=Directory::TAG_NAME[d.tag]
		unless(n.nil?)
		    n=n.name.gsub(/([a-z])([A-Z])/,'\1_\2').downcase
		    self.instance_eval("alias #{n} #{sprintf('x%04x',d.tag)}")
		end
		
		if(d.tag==Directory::ExifIFDPointer||
		   d.tag==Directory::GPSIFDPointer)

		    n=d.tag_name.sub('Pointer','')
		    d.value=Ifd.new(n,x,d.value,&block)

		    #
		    # create method to access ifd
		    #
		    n=n.split('.')[-1].gsub(/([a-z])([A-Z])/,'\1_\2').downcase
		    self.instance_eval("def #{n};self[#{self.size-1}].value;end")
		end
	    }

	    self.flatten!
	    begin
		offset=x.get_ulong(offset)
	    rescue NameError,TypeError
		raise Exif::ParseError,
		    "Invalid offset (#{sprintf("0x%04x",offset)}) "+
		    "given for next ifd of #{@ifd_name}."
	    end
	    
	    # get thumbnail
	    if(@ifd_name=='IFD1')
		if(self.respond_to?('jpeg_interchange_format')&&
		   self.respond_to?('jpeg_interchange_format_length'))
		    #
		    # JPEG thumbnail
		    #
		    thumbnail_offset=self.jpeg_interchange_format.to_i
		    thumbnail_size=self.jpeg_interchange_format_length.to_i
		    unless(thumbnail_offset.nil?||thumbnail_size.nil?)
			begin
			    @thumbnail=x.read_char(thumbnail_offset,thumbnail_size)

			    self.instance_eval('def thumbnail_image;@thumbnail;end')
			    self.instance_eval('def thumbnail_type;:jpeg;end')
			rescue NameError,TypeError
			end
		    end
		elsif(self.respond_to?('strip_offsets')&&
		      self.respond_to?('strip_byte_conunts'))
		    #
		    # TIFF thumbnail
		    #
		    thumbnail_offset=self.strip_offsets
		    thumbnail_size=self.strip_byte_conunts
		    unless(thumbnail_offset.nil?||thumbnail_size.nil?)
			@thumbnail=[]
			o=thumbnail_offset.shift
			s=thumbnail_size.shift
			begin
			    until(o.nil?||s.nil?)
				@thumbnail.push(x.read_char(o,s))
				o=thumbnail_offset.shift
				s=thumbnail_size.shift
			    end
			    self.instance_eval('def thumbnail_image;@thumbnail;end')
			    self.instance_eval('def thumbnail_type;:tiff;end')
			rescue NameError,TypeError
			end
		    end
		end
	    end

	    offset
	end

	def ifds(&block)
	    buf=[]

	    if(block.nil?)
		buf.push(self)
	    else
		if(yield(dir.value))
		    buf.push(self)
		end
	    end
	    
	    self.each{|dir|
		if(dir.is_ifd?)
		    buf.push(dir.value.ifds(&block))
		end
	    }
	    buf
	end

	def ifd(x=nil)
	    if(x.nil?)
		self.ifds.flatten
	    elsif(x.kind_of?(String))
		self.ifds{|ifd|
		    ifd.ifd_name==x
		}.first
	    elsif(x.kind_of?(Regexp))
		self.ifds{|ifd|
		    ifd.ifd_name=~x
		}
	    else
		self.ifds[x]
	    end
	end

	def each_ifd(&block)
	    self.each{|dir|
		if(dir.ifd?)
		    unless(block.nil?)
			yield buf
		    end
		    ifd.each_ifd(&block)
		end
	    }
	end

	def dirs(recursivel=true,&block)
	    buf=[]
	    self.each{|d|
		if(block.nil?)
		    buf.push(d)
		else
		    if(yield(d))
			buf.push(d)
		    end
		end
		if(d.is_ifd?&&recursivel)
		    buf+=d.value.dirs(&block)
		end
	    }
	    buf
	end

	def dir(x,recursivel=false)
	    if(x.kind_of?(String))
		self.dirs(recursivel){|d|
		    d.tag_name==x
		}.first
	    elsif(x.kind_of?(Regexp))
		self.dirs(recursivel){|d|
		    d.tag_name=~x
		}.first
	    else
		self.dirs(recursivel){|d|
		    d.tag==x
		}.first
	    end
	end

	def each_dir(recursivel=true,&block)
	    self.each{|d|
		unless(block.nil?)
		    yield d
		end
		if(d.is_ifd?&&recursivel)
		    d.value.each_dir(recursivel&block)
		end
	    }
	end

	alias tags dirs
	alias tag dir
	alias each_tag each_dir

	def byte_size
	    s=_byte_size_without_thumbnail
	    if(self.respond_to?('jpeg_interchange_format_length'))
		s+=self.jpeg_interchange_format_length.to_i
	    elsif(self.respond_to?('strip_byte_conunts'))
		self.strip_byte_conunts.to_a.each{|val|
		    s+=val.to_i
		}
	    end
	    s
	end

	def dump(offset=0,endian=:le,has_next_lfd=false)
	    #
	    # set thumbnail offset value
	    #
	    thumbnail_offset=offset+_byte_size_without_thumbnail
	    if(self.respond_to?('jpeg_interchange_format'))
		self.jpeg_interchange_format.value=thumbnail_offset
	    elsif(self.respond_to?('strip_offsets')&&
		  self.respond_to?('strip_byte_conunts'))
		buf=[thumbnail_offset]
		self.strip_byte_conunts.to_a[0..-2].each{|s|
		    buf.push(buf[-1]+s)
		}
		self.strip_offsets.value=buf
	    end

	    data_offset=offset+
		self.size*Directory::DIRENT_SIZE+6 # DirEntNum(2)+NextIfd(4)
	    
	    head=Data.new_ushort(self.size,endian).to_s
	    data=''
	    self.each{|dir|
		(h,d)=dir.dump(data_offset,endian)
		head+=h
		unless(d.nil?)
		    data+=d
		    data_offset+=d.size
		end
	    }

	    unless(@thumbnail.nil?)
		@thumbnail.to_a.each{|thumb|
		    data+=thumb.to_s
		}
	    end

	    if(has_next_lfd)
		head+Data.new_ulong(data_offset,endian).to_s+data
	    else
		head+Data.new_ulong(0,endian).to_s+data
	    end
	end

	private
	def _byte_size_without_thumbnail
	    s=6 # Dir.Entry Num(2bytes)+Pointer to Next IFD(4bytes)
	    self.each{|d|
		s+=d.byte_size
	    }
	    s
	end
    end

    #
    # Exif
    #
    EXIF_ID="Exif\x00\x00"
    TIFF_MARKER=0x2a

    def initialize(marker=Jpeg::Segment::APP1,data=nil,size=nil,&block)
	# Exif Header   # "Exif\x00\x00" (6bytes)
	@endian=:le     # TIFF HEADER  # 'II'|'MM' (2bytes)
	# tag mark      #              # "0x2a" (2bytes)
	# offset        #              # offset to data area (4bytes)
        # data area

	@ifd=[]
	@is_exif=false

	super
    end
    attr_reader :ifd

    def is_exif?
	@is_exif
    end

    def parse(data,read_size=nil,&block)
	x=super

	#
	# check exif
	#
	unless(x[0..5]==EXIF_ID)
	    raise Exif::ParseError,'Not Exif (EXIF Header Not found)'
	    return nil
	end

	#
	# check endian
	#
	case x[6..7]
	when "II"
	    @endian=:le
	when "MM"
	    @endian=:be
	else
	    raise Exif::ParseError,"Unknown Endian (#{x[6..7]})"
	    return nil
	end
	x=Data.new(x[6..-1],@endian)

	#
	# check exif again
	#
	unless(x.get_ushort(2)==TIFF_MARKER)
	    raise Exif::ParseError,'Not Exif (TIFF Marker Not found)'
	    return nil
	end
	
	begin
	    offset=x.get_ulong(4)
	    begin
		@ifd.push(Ifd.new("IFD#{@ifd.size}"))
		offset=@ifd[-1].parse(x,offset,&block)
	    end until(offset==0)
	rescue NameError,TypeError
	    raise Exif::ParseError,
		'Broken Exif: Invalid offset given for pointer to IFD0.'
	rescue Exif::ParseError
	    raise Exif::ParseError,
		"Broken Exif: #{$!.to_s}"
	end
	@is_exif=true
	@byte_data='' # to save memory :)

	self
    end

    def size
	unless(@is_exif)
	   return super
	end

	s=16 # data_size(2)+exif_header(6)+byte_alien(2)+
	     #  tag_mark(2)+ifd_offset(4)

	@ifd.each{|ifd|
	    s+=ifd.byte_size
	}
	s
    end

    def byte_data
	unless(@is_exif)
	   return @byte_data
	end

	buf=EXIF_ID
	offset=8 # byte_align(2)+tiff_marker(2)+ifd_offset(4)

	if(@endian==:be)
	    buf+='MM'+[TIFF_MARKER].pack('n')+[offset].pack('N')
	else
	    buf+='II'+[TIFF_MARKER].pack('v')+[offset].pack('V')
	end
	@ifd[0..-2].each{|ifd|
	    d=ifd.dump(offset,@endian,true)
	    offset+=d.size
	    buf+=d
	}
	buf+=@ifd[-1].dump(offset,@endian,false)

	buf
    end

    def ifds(&block)
	buf=[]
	@ifd.each{|ifd|
	    buf.push(ifd.ifds(&block))
	}
	buf
    end

    def ifd(x=nil)
	if(x.nil?)
	    self.ifds.flatten.compact
	else
	    if(x.kind_of?(String))
		self.ifds{|ifd|
		    ifd.ifd_name==x
		}.flatten.compact.first
	    elsif(x.kind_of?(Regexp))
		self.ifds{|ifd|
		    ifd.ifd_name=~x
		}.flatten.compact
	    else
		self.ifds.flatten.compact[x]
	    end
	end
    end

    def each_ifd(&block)
	@ifd.each{|ifd|
	    unless(block.nil?)
		yield buf
	    end
	    ifd.each_ifd(&block)
	}
    end

    def ifd0
	@ifd[0]
    end
    alias image_ifd ifd0 

    def ifd1
	@ifd[1]
    end
    alias thumnail_ifd ifd1

    def exif_ifd
	begin
	    @ifd[0].exif_ifd
	rescue NameError
	    nil
	end
    end

    def interoperability_ifd
	begin
	    @ifd[0].exif_ifd.interoperability_ifd
	rescue NameError
	    nil
	end
    end

    def dirs(&block)
	buf=[]
	@ifd.each{|ifd|
	    buf+=ifd.dirs(&block)
	}
	buf
    end

    def dir(x)
	if(x.kind_of?(String))
	    self.dirs{|d|
		d.tag_name==x
	    }
	elsif(x.kind_of?(Regexp))
	    self.dirs{|d|
		d.tag_name=~x
	    }
	else
	    self.dirs{|d|
		d.tag==x
	    }
	end
    end

    def each_dir(&block)
	@ifd.each{|ifd|
	    ifd.each_tag(&block)
	}
    end

    alias tags dirs
    alias tag dir
    alias each_tag each_dir

    def thumbnail
	begin
	    case @ifd[1].thumbnail_type
	    when :jpeg
		if(@ifd[1].compression==6) 
		    @ifd[1].thumbnail_image
		else
		    nil
		end
	    when :tiff
		# TODO
	    end
	rescue NameError
	    nil
	end
    end

    def has_thumbnail?
	@ifd[1].respond_to?('thumbnail_image')
    end

    def has_jpeg_thumbnail?
	begin
	    if(@ifd[1].thumbnail_type==:jpeg)
		true
	    else
		false
	    end
	rescue NameError
	    false
	end
    end
end

class Exif;class Ifd;class Directory
    Directory.use_proc_for(DateTime,TIME_PARSE_PROC)
    Directory.use_proc_for(DateTimeOriginal,TIME_PARSE_PROC)
    Directory.use_proc_for(DateTimeDigitized,TIME_PARSE_PROC)
end;end;end
