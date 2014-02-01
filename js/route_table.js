// Generated by CoffeeScript 1.6.3
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Routes.RouteTable = (function() {
    function RouteTable(container) {
      this.segment_name_from_points = __bind(this.segment_name_from_points, this);
      this.segment_as_array = __bind(this.segment_as_array, this);
      this.filtered_route_segments = __bind(this.filtered_route_segments, this);
      this.container = container;
      this.route = [];
      this._route_segment_line_string_cache = {};
      this.initialize_svg();
    }

    RouteTable.prototype.initialize_svg = function() {
      this.svg = d3.select('body').select('div#map').append('svg').attr('width', 1200).attr('height', 800);
      this.current_route_group = this.svg.append('g');
      this.potential_route_group = this.svg.append('g');
      return console.log('initialize svg', this.svg);
    };

    RouteTable.prototype.route_points = function(d) {
      if (d) {
        this._route_points = d;
        this._route_points_by_id = this.nest_by_id(d);
        return this;
      }
      return this._route_points;
    };

    RouteTable.prototype.route_segments = function(d) {
      var route_segments, s, _fn, _i, _len;
      if (d) {
        route_segments = [];
        _fn = function(s) {
          route_segments.push(new Routes.RouteSegment(s));
          return route_segments.push(new Routes.RouteSegment(s).reverse());
        };
        for (_i = 0, _len = d.length; _i < _len; _i++) {
          s = d[_i];
          _fn(s);
        }
        this._route_segments = route_segments;
        return this;
      }
      return this._route_segments;
    };

    RouteTable.prototype.nest_by_id = function(d) {
      var nest, object, _i, _len;
      nest = {};
      for (_i = 0, _len = d.length; _i < _len; _i++) {
        object = d[_i];
        nest[object.id] = object;
      }
      return nest;
    };

    RouteTable.prototype.points_as_geojson = function() {
      var point, points, _fn, _i, _len, _ref;
      points = [];
      _ref = this.route_points();
      _fn = function(point) {
        if (point.latitude && point.longitude) {
          return points.push({
            type: "Feature",
            geometry: {
              type: "Point",
              coordinates: [parseFloat(point.longitude), parseFloat(point.latitude)]
            }
          });
        }
      };
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        point = _ref[_i];
        _fn(point);
      }
      return points;
    };

    RouteTable.prototype.render = function() {
      this.render_segments_table();
      return this.render_next_segments_to_map();
    };

    RouteTable.prototype.route_segment_line_string_cache = function(id, callback) {
      var a, rslsc, store_and_execute_callback;
      if (callback == null) {
        callback = (function() {
          return null;
        });
      }
      if (a = this._route_segment_line_string_cache[id]) {
        return callback(a);
      } else {
        rslsc = this._route_segment_line_string_cache;
        store_and_execute_callback = function(result) {
          rslsc[id] = result;
          return callback(result);
        };
        return (new Routes.GPXParser).parse_gpx("data/gpx/" + id + ".gpx", 'line_string', store_and_execute_callback);
      }
    };

    RouteTable.prototype.projection = function(proj) {
      if (proj) {
        this._projection = proj;
        return this;
      }
      return this._projection;
    };

    RouteTable.prototype.render_path_to_map = function(path_id, options) {
      var cache, group, projection, render_callback;
      if (options == null) {
        options = {};
      }
      projection = this.projection();
      group = options.group || this.current_route_group;
      cache = this._route_segment_line_string_cache;
      render_callback = function(result) {
        var path, point;
        path = d3.geo.path().projection(projection);
        return point = group.append('path').attr('id', "#route_path_" + path_id).datum(result).attr('d', path).style('stroke', options.color || 'blue').style('stroke-width', '1.5pt').style('stroke-dasharray', options.stroke_dasharray || 'none').style('fill', 'none');
      };
      return this.route_segment_line_string_cache(path_id, render_callback);
    };

    RouteTable.prototype.render_next_segments_to_map = function() {
      var potential_route, _i, _len, _ref, _results,
        _this = this;
      this.potential_route_group.selectAll('path').remove();
      _ref = this.filtered_route_segments();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        potential_route = _ref[_i];
        _results.push((function(potential_route) {
          if (potential_route.mappable()) {
            return _this.render_path_to_map(potential_route.id, {
              color: 'red',
              group: _this.potential_route_group,
              stroke_dasharray: '3,3'
            });
          }
        })(potential_route));
      }
      return _results;
    };

    RouteTable.prototype.render_points_to_map = function() {
      var path, points;
      path = d3.geo.path().projection(this._context_map.projection()).pointRadius(4);
      console.log(this.points);
      points = this._context_map.group.selectAll('.route_point').data(this.points_as_geojson());
      return points.enter().append('path').attr('class', 'route_point').attr('d', path).style('fill', 'red');
    };

    RouteTable.prototype.filtered_route_segments = function() {
      var end, last_segment, x, _i, _j, _len, _len1, _ref, _ref1, _results, _results1;
      if (this.route.length === 0) {
        _ref = this.route_segments();
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          x = _ref[_i];
          if (x.start_point_id() === 2) {
            _results.push(x);
          }
        }
        return _results;
      } else {
        last_segment = this.route[this.route.length - 1];
        end = last_segment.end_point_id();
        _ref1 = this.route_segments();
        _results1 = [];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          x = _ref1[_j];
          if (x.start_point_id() === end) {
            _results1.push(x);
          }
        }
        return _results1;
      }
    };

    RouteTable.prototype.render_segments_table = function() {
      var controls, rs, segments_table, tds,
        _this = this;
      segments_table = d3.select(this.container).select('#segments');
      rs = segments_table.selectAll('tr.segment').data(this.filtered_route_segments());
      rs.enter().append('tr').attr('class', 'segment');
      tds = rs.selectAll('td').data(this.segment_as_array);
      tds.enter().append('td');
      tds.text(function(d) {
        return d;
      });
      rs.selectAll('td.controls').remove();
      controls = rs.append('td').attr('class', 'controls');
      controls.append('a').attr('href', '#').on('click', function(d) {
        return _this.add_to_route(d);
      }).text('add');
      return rs.exit().remove();
    };

    RouteTable.prototype.add_to_route = function(d) {
      var s, _fn, _i, _len, _ref,
        _this = this;
      _ref = d.components();
      _fn = function(s) {
        _this.route.push(s);
        return _this.render_path_to_map(s.id);
      };
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        s = _ref[_i];
        _fn(s);
      }
      this.render_route_table();
      this.render_segments_table();
      return this.render_next_segments_to_map();
    };

    RouteTable.prototype.render_route_table = function() {
      var route_table, rt, summary, tds, total;
      route_table = d3.select(this.container).select('#route');
      rt = route_table.selectAll('tr.segment').data(this.route);
      total = route_table.selectAll('tr.total').remove();
      rt.enter().append('tr').attr('class', 'segment');
      tds = rt.selectAll('td').data(this.segment_as_array);
      tds.enter().append('td');
      tds.text(function(d) {
        return d;
      });
      total = route_table.append('tr').attr('class', 'total');
      total.append('td');
      total.append('td').text('total:');
      summary = this.route_summary();
      total.append('td').text(summary.miles);
      total.append('td').text(summary.elevation);
      return rt.exit().remove();
    };

    RouteTable.prototype.segment_as_array = function(segment) {
      return [segment.id, this.segment_name(segment), this.miles(segment), this.elevation(segment), this.reverse_elevation(segment)];
    };

    RouteTable.prototype.segment_name = function(segment) {
      return segment.name() || this.segment_name_from_points(segment);
    };

    RouteTable.prototype.render_points_table = function() {
      var points_table, rp;
      points_table = d3.select(this.container).select('#points');
      rp = points_table.selectAll('tr.point').data(this.route_points());
      rp.enter().append('tr').attr('class', 'point');
      rp.append('td').text(function(d) {
        return d.id;
      });
      rp.append('td').text(function(d) {
        return d.name;
      });
      return rp.exit().remove();
    };

    RouteTable.prototype.segment_name_from_points = function(segment) {
      var e, r, s;
      s = segment.start_point_id();
      e = segment.end_point_id();
      r = this._route_points_by_id;
      return "" + s + "-[" + r[s].name + "] to " + e + "-[" + r[e].name + "]";
    };

    RouteTable.prototype.miles = function(segment) {
      return "" + (segment.miles()) + " mi";
    };

    RouteTable.prototype.elevation = function(segment) {
      return "" + (segment.elevation()) + " ft";
    };

    RouteTable.prototype.reverse_elevation = function(segment) {
      return "(" + (segment.reverse_elevation()) + " ft)";
    };

    RouteTable.prototype.route_summary = function() {
      var elevation, miles, segment, _fn, _i, _len, _ref;
      miles = 0;
      elevation = 0;
      _ref = this.route;
      _fn = function(segment) {
        miles += segment.miles();
        return elevation += segment.elevation();
      };
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        segment = _ref[_i];
        _fn(segment);
      }
      return {
        miles: miles.toFixed(1),
        elevation: elevation
      };
    };

    RouteTable.prototype.context_map = function(json, dataset_name, options) {
      if (options == null) {
        options = {};
      }
      return this._context_map = new Routes.ContextMap(this.svg, json, dataset_name, options);
    };

    return RouteTable;

  })();

}).call(this);
