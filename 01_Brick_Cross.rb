@mod = Sketchup.active_model
@viw = @mod.active_view
@sel = @mod.selection
@ent = @mod.entities

def make_face(pt,v,n1,n2)
  pts=[];
  m_num = Math.sqrt((n1*v.x)**2+(n1*v.y)**2+n2**2)
  l_num = Math.sqrt(n1**2+n2**2)
  m_vec = [v.x*n1/m_num , v.y*n1/m_num, n2/m_num]
  pts << pt
  pts << pt.offset(v,n1)
  pts << pt.offset(m_vec,l_num)
  pts << pt.offset([0,0,1],n2)
  return pts
end

def unit_vec(vec)
  len = Math.sqrt(vec.x**2+vec.y**2)
  n_vec = [vec.x/len, vec.y/len,0]
end

in_mm = 25.4

brick_w = 200 / in_mm
brick_h = 100 / in_mm
mold_d = 50 / in_mm
mold_h = 80 / in_mm

_face = @sel.grep(Sketchup::Face)
for f in _face
  f.pushpull(mold_h*(-1))
  btm = f.edges.min_by{|x|x.start.position.z+x.end.position.z}
  upp = f.edges.max_by{|x|x.start.position.z+x.end.position.z}
  spt = btm.start.position
  ept = btm.end.position
  upt = upp.start.position
  
  u_vec = unit_vec(ept-spt)
  u_vec = [u_vec.x,u_vec.y,0]
  if u_vec.x < 0.0000000001
    u_vec = [0,u_vec.y,0]
  elsif u_vec.y < 0.0000000001
    u_vec = [u_vec.x,0,0]
  end
  
  origin_pt = Geom::Point3d.new(spt)
  _wd = Math.sqrt((spt.x-ept.x)**2+(spt.y-ept.y)**2)
  _wh = upt.z - spt.z
  
  wd_num = (_wd/(brick_w+mold_d))
  wd_num = wd_num.floor
  hd_num = (_wh/(brick_h+mold_d))
  hd_num = hd_num.floor
  
  num_d = _wd - (wd_num)*(brick_w+mold_d)
  num_h = _wh - (hd_num)*(brick_h+mold_d)
  num_j1 = ((brick_w+mold_d)/2) + num_d
  num_jj = ((brick_w+mold_d)/2) - num_d
  num_d = brick_w if num_d>brick_w
  num_h = brick_h if num_h>brick_h
  num_j1 = brick_w if num_j1>brick_w
  
  for i in (0..hd_num)
    for j in (0..wd_num)
      if(i%2==0)
        if(j==0)
          act_pt = origin_pt.offset([0,0,1],i*(brick_h+mold_d))
          @ent.add_face(make_face(act_pt,u_vec,(brick_w-mold_d)/2,brick_h)).pushpull(mold_h)
        end
        arr_pt = origin_pt.offset(u_vec,(j+0.5)*(brick_w+mold_d)).offset([0,0,1],i*(brick_h+mold_d))
        if num_j1 == brick_w
          if j==wd_num||i==hd_num
            if i!=hd_num
              if num_jj>0
                @ent.add_face(make_face(arr_pt,u_vec,num_jj,brick_h)).pushpull(mold_h)
              end
            elsif j!=wd_num
              @ent.add_face(make_face(arr_pt,u_vec,brick_w,num_h)).pushpull(mold_h)
            else
              if num_jj>0
                @ent.add_face(make_face(arr_pt,u_vec,num_jj,num_h)).pushpull(mold_h)
              end
            end
          else  
            @ent.add_face(make_face(arr_pt,u_vec,brick_w,brick_h)).pushpull(mold_h)
          end
        else
          if j==(wd_num-1)||i==hd_num
            if i!=hd_num
              @ent.add_face(make_face(arr_pt,u_vec,num_j1,brick_h)).pushpull(mold_h)
            elsif j != (wd_num-1)
              @ent.add_face(make_face(arr_pt,u_vec,brick_w,num_h)).pushpull(mold_h)
            else
              @ent.add_face(make_face(arr_pt,u_vec,num_jj,num_h)).pushpull(mold_h)
            end
          elsif j!=wd_num
            @ent.add_face(make_face(arr_pt,u_vec,brick_w,brick_h)).pushpull(mold_h)
          end
        end
      else
        arr_pt = origin_pt.offset(u_vec,j*(brick_w+mold_d)).offset([0,0,1],i*(brick_h+mold_d))
        if j==wd_num||i==hd_num
          if i!=hd_num
            @ent.add_face(make_face(arr_pt,u_vec,num_d,brick_h)).pushpull(mold_h)
          elsif j!=wd_num
            @ent.add_face(make_face(arr_pt,u_vec,brick_w,num_h)).pushpull(mold_h)
          else
            @ent.add_face(make_face(arr_pt,u_vec,num_d,num_h)).pushpull(mold_h)
          end
        else  
          @ent.add_face(make_face(arr_pt,u_vec,brick_w,brick_h)).pushpull(mold_h)
        end
      end
    end
  end
end
