#
# day2section.rb - tDiary plugin
#
# When a visitor accesses to day page without section anchor, navigate to first section.
#
# Copyright (c) MATSUOKA Kohei <http://www.machu.jp/>
# Distributed under the GPL
#
add_footer_proc do
  if @mode == 'day'
    <<-SCRIPT
    <script type="text/javascript">
    if(!location.hash) {
      location.replace(location.hash + "#p01");
    }
    </script>
    SCRIPT
  end
end

