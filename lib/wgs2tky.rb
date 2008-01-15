#
# wgs2tky.rb
#  -- GPS data converter
#
# kp<k-nomura@s6.dion.ne.jp>
#

class Wgs2Tky

  Pi = Math::PI
  Rd = Pi/180

  # WGS84
  A = 6378137.0                # ê‘ìπîºåa
  F = 1/298.257223563          # ùGïΩó¶
  E2 = F*2 - F*F               # ëÊàÍó£êSó¶

  # Tokyo
  A_ = 6378137.0 - 739.845     # 6377397.155
  F_ = 1/298.257223563 - 0.000010037483
                               # 1 / 299.152813
  E2_ = F_*2 - F_*F_

  Dx = +128
  Dy = -481
  Dz = -664	

  def Wgs2Tky.conv!(lat,lon,h = 0)
    b = lat[0].to_f + lat[1].to_f/60 + lat[2].to_f/3600
    l = lon[0].to_f + lon[1].to_f/60 + lon[2].to_f/3600
		
    (x,y,z) = Wgs2Tky._llh2xyz(b,l,h,A,E2)
		
    x+=Dx
    y+=Dy
    z+=Dz

    (b,l,h) = Wgs2Tky._xyz2llh(x,y,z,A_,E2_)

    lat[0..2]=Wgs2Tky._deg2gdms(b)
    lon[0..2]=Wgs2Tky._deg2gdms(l)
  end
	
  private

  include Math
  extend Math

  def Wgs2Tky._llh2xyz(b,l,h,a,e2)

    b *= Rd
    l *= Rd
		
    sb = sin(b)
    cb = cos(b)

    rn = a / Math.sqrt(1-e2*sb*sb)
    
    x = (rn+h)*cb*cos(l)
    y = (rn+h)*cb*sin(l)
    z = (rn*(1-e2)+h) * sb
		
    return x,y,z
  end

  def Wgs2Tky._xyz2llh(x,y,z,a,e2)

    bda = sqrt(1-e2)
	
    po = sqrt(x*x+y*y)
    t = atan2(z,po*bda)
    st = sin(t)
    ct = cos(t)
    b = atan2(z+e2*a/bda*st*st*st,po-e2*a*ct*ct*ct)
    l = atan2(y,x)

    sb = sin(b)
    rn = a / sqrt(1-e2*sb*sb)
    h = po / cos(b) - rn
		
    return b/Rd,l/Rd,h
  end

  def Wgs2Tky._deg2gdms(deg)
    sf = (deg*36000+0.5).to_i
    s = (sf/10).to_i%60
    m = (sf/600).to_i%60
    d = (sf/36000).to_i
    sf%=10
    s = "#{s}.#{sf}".to_f	
    return d,m,s
  end
end

