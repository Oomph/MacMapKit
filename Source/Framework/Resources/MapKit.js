/*jslint vars: true, nomen: true, browser: true, indent: 4 */

/**
 * @param w the window
 * @param d the document
 * @param g the google class
 */
(function (w, d, g) {
    "use strict";

    /**
     * A utility function to bind "this" in a function to a particular object
     * https://developer.mozilla.org/en-US/docs/JavaScript/Reference/Global_Objects/Function/bind
     */
    if (!Function.prototype.bind) {
        Function.prototype.bind = function (oThis) {
            var aArgs = Array.prototype.slice.call(arguments, 1),
                fToBind = this,
                FNOP = function () {},
                fBound = function () {
                    return fToBind.apply((this instanceof FNOP && oThis ? this : oThis), aArgs.concat(Array.prototype.slice.call(arguments)));
                };

            if (typeof this !== "function") {
                // closest thing possible to the ECMAScript 5 internal
                // IsCallable function
                throw new TypeError("Function.prototype.bind - what is trying to be bound is not callable");
            }

            FNOP.prototype = this.prototype;
            fBound.prototype = new FNOP();

            return fBound;
        };
    }

    /**
     * A utility function to mix in methods from one object into another
     */
    function mix(to, from) {
        var prop;
        for (prop in from) {
            if (from.hasOwnProperty(prop)) {
                to[prop] = from[prop];
            }
        }
    }

    /**
     * A utility function to extend one class from another and add extra
     * instance methods
     * 
     * @return the new klass
     */
    function extend(klass, parentKlass, instanceMethods, classMethods) {
        var SimpleParentKlass;

        if (parentKlass) {
            SimpleParentKlass = function () {};
            SimpleParentKlass.prototype = parentKlass.prototype;
            klass.prototype = new SimpleParentKlass();
            klass.uber = parentKlass.prototype;
            klass.prototype.constructor = klass;
        }

        if (instanceMethods) {
            mix(klass.prototype, instanceMethods);
        }

        if (classMethods) {
            mix(klass, classMethods);
        }

        return klass;
    }

    /**
     * Define a document.getElementsByClassName if it isn't already defined
     */
    if (!d.getElementsByClassName) {
        d.getElementsByClassName = function (cl) {
            var i,
                classes,
                retnode = [],
                myclass = new RegExp('\\b' + cl + '\\b'),
                elem = this.getElementsByTagName('*');

            for (i = 0; i < elem.length; i += 1) {
                classes = elem[i].className;
                if (myclass.test(classes)) {
                    retnode.push(elem[i]);
                }
            }
            return retnode;
        };
    }

    /**
     * Define a window.onwebkitanimationend to perform certain actions when an
     * animation has ended
     */
    w.onwebkitanimationend = function (event) {
        var annotationCallouts,
            annotationCallout,
            i,
            e = event || w.event;

        if (e.animationName === "annotationCalloutPulse") {
            annotationCallouts = d.getElementsByClassName("annotationCalloutWrapper annotationCalloutPulseAnimation");
            for (i = 0; i < annotationCallouts.length; i += 1) {
                annotationCallout = annotationCallouts[i];
                annotationCallout.className = "annotationCalloutWrapper";
            }
        }
    };

    /**
     * UserLocationOverlayView, extends g.maps.OverlayView
     */
    w.UserLocationOverlayView = extend(

        function () {
            // We define a property to hold the image's div. We'll
            // actually create this div upon receipt of the onAdd()
            // method so we'll leave it null for now.
            this.div_ = null;
            this.radius_ = 0;
            this.center_ = new g.maps.LatLng(0, 0);
        },
        g.maps.OverlayView,
        {
            setCenter: function (center) {
                this.center_ = center;
            },

            setRadius: function (radius) {
                this.radius_ = radius;
            },

            onAdd: function () {

                // Note: an overlay's receipt of onAdd() indicates that
                // the map's panes are now available for attaching
                // the overlay to the map via the DOM.

                // Create the DIV and set some basic attributes.
                var div = d.createElement('div');
                div.style.borderStyle = "none";
                div.style.borderWidth = "0px";
                div.style.position = "absolute";
                div.className = "userLocation";

                var innerUserLocationDiv = d.createElement('div');
                div.appendChild(innerUserLocationDiv);

                var beaconDiv = d.createElement('div');
                beaconDiv.className = "beacon growAnimation";
                innerUserLocationDiv.appendChild(beaconDiv);

                var dotDiv = d.createElement('div');
                dotDiv.className = "dot";
                innerUserLocationDiv.appendChild(dotDiv);

                // Set the overlay's div_ property to this DIV
                this.div_ = div;

                // We add an overlay to a map via one of the map's panes.
                // We'll add this overlay to the overlayImage pane.
                var panes = this.getPanes();
                panes.overlayImage.appendChild(div);
            },

            draw: function () {

                // Size and position the overlay. We use a southwest and
                // northeast
                // position of the overlay to peg it to the correct position
                // and
                // size.
                // We need to retrieve the projection from this overlay to
                // do this.
                var overlayProjection = this.getProjection();

                // Retrieve the southwest and northeast coordinates of this
                // overlay
                // in latlngs and convert them to pixels coordinates.
                // We'll use these coordinates to resize the DIV.
                // get bounds by faking a circle
                var circle = new g.maps.Circle();
                circle.setRadius(this.radius_);
                circle.setCenter(this.center_);
                var bounds = circle.getBounds();
                var sw = overlayProjection.fromLatLngToDivPixel(bounds.getSouthWest());
                var ne = overlayProjection.fromLatLngToDivPixel(bounds.getNorthEast());

                // Resize the image's DIV to fit the indicated dimensions.
                var div = this.div_;
                div.style.left = sw.x + 'px';
                div.style.top = ne.y + 'px';
                div.style.width = (ne.x - sw.x) + 'px';
                div.style.height = (sw.y - ne.y) + 'px';
            },

            onRemove: function () {
                this.div_.parentNode.removeChild(this.div_);
                this.div_ = null;
            }
        }
    );

    /**
     * AnnotationOverlayView, extends g.maps.OverlayView
     */
    w.AnnotationOverlayView = extend(
        function () {
            // We define a property to hold the image's div. We'll
            // actually create this div upon receipt of the onAdd()
            // method so we'll leave it null for now.
            this.div_ = null;
            this.imageUrl_ = null;
            this.imageTag_ = null;
            this.marker_ = null;
            this.calloutWrapper_ = null;
            this.calloutCanvas_ = null;
            this.calloutText_ = null;
            this.set('position', new g.maps.LatLng(0, 0));
            this.marker_ = new g.maps.Marker();
            var markerImage = new g.maps.MarkerImage('TransparentPixel.png', new g.maps.Size(1, 1), null, null, null);
            this.marker_.setIcon(markerImage);
            this.marker_.bindTo('map', this);
            this.marker_.bindTo('position', this);
            var me = this;
            // Figure out a better way to call draw when position has
            // changed.
            g.maps.event.addListener(this.marker_, 'position_changed', function () {
                me.draw();
            });

            this.createCallout();
        },
        g.maps.OverlayView,
        {
            getMarker: function () {
                return this.marker_;
            },

            setImageUrl: function (url) {
                this.imageUrl_ = url;
                if (this.imageTag_) {
                    this.imageTag_.src = url;
                }
            },

            getImageUrl: function () {
                return this.imageUrl_;
            },

            setOptions: function (options) {
                // g.maps.OverlayView.prototype.setOptions(this, options);
                var marker = this.marker_;
                var annotation = this;
                var option;

                for (option in options) {
                    if (options.hasOwnProperty(option)) {
                        var value = options[option];
                        if (option === "imageUrl") {
                            annotation.setImageUrl(value);
                        } else if (option === "position") {
                            annotation.set('position', value);
                        } else if (option === "draggable") {
                            marker.setOptions({
                                "draggable": value
                            });
                            marker.setOptions({
                                "optimized": false
                            });
                            marker.setClickable(true);
                        } else if (option === "title") {
                            annotation.setCalloutText(value);
                        } else if (option === "zIndex") {
                            marker.setOptions({
                                "zIndex": value
                            });
                            if (annotation.div_) {
                                annotation.div_.style.zIndex = value;
                            }
                            if (annotation.imageTag_) {
                                annotation.imageTag_.style.zIndex = value;
                            }
                            if (annotation.calloutWrapper_) {
                                annotation.calloutWrapper_.style.zIndex = value;
                            }
                        } else if (option === "animatesDrop") {
                            if (value) {
                                marker.setAnimation(g.maps.Animation.DROP);
                            } else {
                                marker.setAnimation(null);
                            }
                        }
                    }
                }
            },

            updateMarker: function () {
                var imageHeight = this.imageTag_.offsetHeight;
                var imageWidth = this.imageTag_.offsetWidth;
                var markerImage = new g.maps.MarkerImage('TransparentPixel.png', new g.maps.Size(imageWidth, imageHeight), null, null, null);
                this.marker_.setIcon(markerImage);
            },

            createCallout: function () {
                /*
                 * Creates something that looks like this:
                 * <div class="annotationCalloutWrapper">
                 *     <canvas class="annotationCallout"></canvas>
                 *     <div class="annotationCalloutTextWrapper">
                 *         <span class="annotationCalloutText">asfd</span>
                 *     </div>
                 * </div>
                 */
                var calloutWrapperDiv = d.createElement('div');
                calloutWrapperDiv.className = "annotationCalloutWrapper";

                var canvasElement = d.createElement("canvas");
                canvasElement.className = "annotationCallout";
                calloutWrapperDiv.appendChild(canvasElement);

                var calloutTextWrapperDiv = d.createElement("div");
                calloutTextWrapperDiv.className = "annotationCalloutTextWrapper";
                calloutWrapperDiv.appendChild(calloutTextWrapperDiv);

                var calloutTextSpan = d.createElement("span");
                calloutTextSpan.className = "annotationCalloutText";
                calloutTextWrapperDiv.appendChild(calloutTextSpan);

                this.calloutWrapper_ = calloutWrapperDiv;
                this.calloutCanvas_ = canvasElement;
                this.calloutText_ = calloutTextSpan;
            },

            drawCallout: function () {

                // get the canvas element using the DOM
                var canvas = this.calloutCanvas_;
                // use getContext to use the canvas for drawing
                var ctx = canvas.getContext('2d');

                var width = canvas.offsetWidth;
                var height = canvas.offsetHeight;
                // Reset the coordinate space.
                canvas.width = width;
                canvas.height = height;
                var offset = 0.5;

                var radius = 5.0;
                var TIP_HEIGHT = 13;
                var TIP_WIDTH = 27;
                var MARGIN = 4.0;
                var minx = MARGIN + offset;
                var midx = Math.round((width - MARGIN) / 2) + offset;
                var maxx = width - 2 * MARGIN + offset;
                var miny = MARGIN + offset;
                var midy = MARGIN + Math.round((height - 2 * MARGIN) / 2.0) - Math.round(TIP_HEIGHT / 2) + offset;
                var maxy = height - 2 * MARGIN - TIP_HEIGHT + offset;

                var tipTopLeftX = midx - Math.round(TIP_WIDTH / 2);
                var tipTopLeftY = maxy;
                var tipTopRightX = midx + Math.round(TIP_WIDTH / 2);
                var tipTopRightY = maxy;
                var tipBottomX = midx;
                var tipBottomY = maxy + TIP_HEIGHT;

                ctx.beginPath();
                ctx.moveTo(minx, midy); // left edge
                ctx.arc(minx + radius, miny + radius, radius, Math.PI, (3 / 2) * Math.PI, false); // top
                // left
                // corner
                // to
                // top
                // edge
                ctx.arc(maxx - radius, miny + radius, radius, (3 / 2) * Math.PI, 0, false); // top
                // right
                // corner,
                // to
                // right
                // edge
                ctx.arc(maxx - radius, maxy - radius, radius, 0, (1 / 2) * Math.PI, false); // bottom
                // right
                // corner,
                // to
                // bottom
                // edge
                ctx.lineTo(tipTopRightX, tipTopRightY); // down to tip
                ctx.lineTo(tipBottomX, tipBottomY); // down to tip
                ctx.lineTo(tipTopLeftX, tipTopLeftY); // back up to bottom
                // edge-ish.
                ctx.arc(minx + radius, maxy - radius, radius, (1 / 2) * Math.PI, Math.PI, false); // bottom
                // left
                // corner,
                // to
                // left
                // edge
                ctx.closePath();

                // Prep to draw shadow (WebKit doesn't support drawing
                // shadows on
                // gradients, so a hack is needed.)
                ctx.shadowBlur = 6;
                ctx.shadowOffsetX = 0;
                ctx.shadowOffsetY = 3;
                ctx.shadowColor = 'rgba(0,0,0,0.4);';
                ctx.fill();

                // Clear the path to draw the real stuff.
                ctx.save();
                ctx.globalCompositeOperation = 'copy';
                ctx.fillStyle = 'rgba(0,0,0,0)';
                ctx.fill();
                ctx.restore();

                // Draw real fill
                var lingrad = ctx.createLinearGradient(0, 0, 0, maxy);
                lingrad.addColorStop(0, 'rgba(130,130,130,0.62);');
                lingrad.addColorStop(0.55, 'rgba(55,55,55,0.62);');
                lingrad.addColorStop(0.5501, 'rgba(20,20,20,0.62);');
                lingrad.addColorStop(1, 'rgba(10,10,10,0.62);');
                ctx.lineWidth = 1;
                ctx.strokeStyle = '#555'; // 'rgba(0.9,0.9,0.9,1.0)';
                ctx.stroke();
                ctx.fillStyle = lingrad;
                ctx.fill();

                minx = minx + 1;
                maxx = maxx - 1;
                miny = miny + 1;
                maxy = maxy - 1;

                tipTopLeftY = tipTopLeftY - 1;
                tipTopRightY = tipTopRightY - 1;
                tipBottomY = tipBottomY - 1;

                ctx.beginPath();
                ctx.moveTo(minx, midy); // left edge
                ctx.arc(minx + radius, miny + radius, radius, Math.PI, (3 / 2) * Math.PI, false); // top
                // left
                // corner
                // to
                // top
                // edge
                ctx.arc(maxx - radius, miny + radius, radius, (3 / 2) * Math.PI, 0, false); // top
                // right
                // corner,
                // to
                // right
                // edge
                ctx.arc(maxx - radius, maxy - radius, radius, 0, (1 / 2) * Math.PI, false); // bottom
                // right
                // corner,
                // to
                // bottom
                // edge
                ctx.lineTo(tipTopRightX, tipTopRightY); // down to tip
                ctx.lineTo(tipBottomX, tipBottomY); // down to tip
                ctx.lineTo(tipTopLeftX, tipTopLeftY); // back up to bottom
                // edge-ish.
                ctx.arc(minx + radius, maxy - radius, radius, (1 / 2) * Math.PI, Math.PI, false); // bottom
                // left
                // corner,
                // to
                // left
                // edge
                ctx.closePath();

                lingrad = ctx.createLinearGradient(0, 0, 0, height);
                lingrad.addColorStop(0, 'rgba(250,250,250,0.95);');
                lingrad.addColorStop(0.3, 'rgba(130,130,130,0.1);');
                lingrad.addColorStop(0.75, 'rgba(150,150,150,0.1);');
                lingrad.addColorStop(1, 'rgba(210,210,210,0.2);');
                ctx.lineWidth = 1;
                ctx.strokeStyle = lingrad;
                ctx.stroke();

                // draw text.
                ctx.fillStyle = "#fff";
                ctx.font = "bold 16px Lucida Grande";
                var text = this.calloutText_.innerHTML;
                var textSize = ctx.measureText(text);
                var ellipsisText = "...";
                var ellipsisTextSize = ctx.measureText(ellipsisText);
                var MAX_WIDTH = 250;
                var truncated = false;

                if (textSize.width > MAX_WIDTH) {
                    while (textSize.width + ellipsisTextSize.width > MAX_WIDTH) {
                        text = text.substring(0, text.length - 1);
                        textSize = ctx.measureText(text);
                    }
                    truncated = true;
                }
                if (truncated) {
                    text = text + ellipsisText;
                }
                ctx.shadowBlur = 1;
                ctx.shadowOffsetX = 0;
                ctx.shadowOffsetY = -1;
                ctx.shadowColor = 'rgba(0,0,0,1);';

                var leftOffset = this.calloutText_.offsetLeft;
                ctx.fillText(text, leftOffset, 30);
            },

            setCalloutText: function (newText) {
                this.calloutText_.innerHTML = newText;
                this.drawCallout();
            },

            pulseCallout: function () {
                this.calloutWrapper_.className = "annotationCalloutWrapper annotationCalloutPulseAnimation";
            },

            placeCallout: function () {
                if (this.div_ === null) {
                    return;
                }

                if (this.calloutWrapper_ === null) {
                    return;
                }

                var annotationCalloutElementWidth = this.calloutWrapper_.offsetWidth;
                var annotationCalloutElementHeight = this.calloutWrapper_.offsetHeight;
                var annotationElementCenterX = this.div_.offsetLeft + (this.div_.offsetWidth / 2);
                var annotationElementTop = this.div_.offsetTop;

                this.calloutWrapper_.style.left = (annotationElementCenterX - (annotationCalloutElementWidth / 2)) + 2 + "px";
                this.calloutWrapper_.style.top = (annotationElementTop - annotationCalloutElementHeight) + 5 + "px";
            },

            setCalloutHidden: function (isHidden) {
                if (isHidden) {
                    this.calloutWrapper_.style.display = "none";
                } else {
                    this.calloutWrapper_.style.display = "block";
                    this.drawCallout();
                    this.placeCallout();
                    this.pulseCallout();
                }
            },

            onAdd: function () {

                // Note: an overlay's receipt of onAdd() indicates that
                // the map's panes are now available for attaching
                // the overlay to the map via the DOM.

                // Create the DIV and set some basic attributes.
                var div = d.createElement('div');
                div.className = "dropAnimation";
                div.style.borderStyle = "none";
                div.style.borderWidth = "0px";
                div.style.position = "absolute";

                var imageTag = d.createElement('img');
                imageTag.addEventListener(
                    'error',
                    function () {
                        this.draw();
                    }.bind(this),
                    false
                );

                imageTag.addEventListener(
                    'load',
                    function () {
                        this.updateMarker();
                        this.draw();
                    }.bind(this),
                    false
                );
                this.imageTag_ = imageTag;

                div.appendChild(imageTag);
                // Set the overlay's div_ property to this DIV
                this.div_ = div;

                // We add an overlay to a map via one of the map's panes.
                // We'll add this overlay to the overlayImage pane.
                var panes = this.getPanes();
                panes.overlayImage.appendChild(div);
                panes.overlayImage.appendChild(this.calloutWrapper_);

                // set the image in case it's been set before we got here
                this.setImageUrl(this.imageUrl_);
            },

            draw: function () {
                if (!this.div_) {
                    return;
                }
                                     
                // Size and position the overlay. We use a southwest and
                // northeast
                // position of the overlay to peg it to the correct position
                // and
                // size.
                // We need to retrieve the projection from this overlay to
                // do this.
                var overlayProjection = this.getProjection();

                // Retrieve the southwest and northeast coordinates of this
                // overlay
                // in latlngs and convert them to pixels coordinates.
                // We'll use these coordinates to resize the DIV.
                // get bounds by faking a circle

                var pxPoint = overlayProjection.fromLatLngToDivPixel(this.get('position'));
                var imageWidth = this.imageTag_.offsetWidth;
                var imageHeight = this.imageTag_.offsetHeight;

                // Resize the image's DIV to fit the indicated dimensions.
                var div = this.div_;
                div.style.left = pxPoint.x - imageWidth / 2.0 + 'px';
                div.style.top = pxPoint.y - imageHeight + 'px';
                div.style.width = imageWidth + 'px';
                div.style.height = imageHeight + 'px';
                this.placeCallout();
                this.drawCallout();
            },

            onRemove: function () {
                this.calloutWrapper_.parentNode.removeChild(this.calloutWrapper_);
                this.div_.parentNode.removeChild(this.div_);
                this.div_ = null;
            }
        }
    );

    /**
     * Window Methods
     */
    mix(w, {
        getMapType: function () {
            var mapType = g.maps.MapTypeId.ROADMAP;
            switch (w.map.mapTypeId) {
            case g.maps.MapTypeId.ROADMAP:
                mapType = 0;
                break;
            case g.maps.MapTypeId.SATELLITE:
                mapType = 1;
                break;
            case g.maps.MapTypeId.HYBRID:
                mapType = 2;
                break;
            default:
                mapType = 0;
            }
            return mapType;
        },

        setMapType: function (mapType) {
            if (mapType === 0) {
                w.map.setMapTypeId(g.maps.MapTypeId.ROADMAP);
            } else if (mapType === 1) {
                w.map.setMapTypeId(g.maps.MapTypeId.SATELLITE);
            } else if (mapType === 2) {
                w.map.setMapTypeId(g.maps.MapTypeId.HYBRID);
            }
            return 0;
        },

        getCenterCoordinate: function () {
            var latlong = w.map.getCenter();
            return JSON.stringify({
                "latitude": latlong.lat(),
                "longitude": latlong.lng()
            });
        },

        setCenterCoordinateAnimated: function (lat, lng, animated) {
            var latlng = new g.maps.LatLng(lat, lng);
            if (animated === true) {
                w.map.panTo(latlng);
            } else {
                w.map.setCenter(latlng);
            }
        },

        getRegion: function () {
            var latlongBounds = w.map.getBounds(),
                value = {
                    "center": {
                        "latitude": latlongBounds.getCenter().lat(),
                        "longitude": latlongBounds.getCenter().lng()
                    },
                    "latitudeDelta": latlongBounds.toSpan().lat(),
                    "longitudeDelta": latlongBounds.toSpan().lng()
                };
            return JSON.stringify(value);
        },

        setRegionAnimated: function (centerLatitude, centerLongitude, latitudeDelta, longitudeDelta, animated) {
            var sw = new g.maps.LatLng(centerLatitude - latitudeDelta / 2.0, centerLongitude - longitudeDelta / 2.0),
                ne = new g.maps.LatLng(centerLatitude + latitudeDelta / 2.0, centerLongitude + longitudeDelta / 2.0),
                bounds = new g.maps.LatLngBounds(sw, ne);
            if (animated === true) {
                w.map.panToBounds(bounds);
            } else {
                w.map.fitBounds(bounds);
            }
        },

        // User Location Functions

        createUserLocationMarker: function () {
            w.userLocationMarker = new w.UserLocationOverlayView();
        },

        setUserLocationLatitudeLongitude: function (lat, lng) {
            var latlng = new g.maps.LatLng(lat, lng);
            w.userLocationMarker.setCenter(latlng);
        },

        setUserLocationRadius: function (meters) {
            w.userLocationMarker.setRadius(meters);
        },

        setUserLocationVisible: function (visible) {
            w.userLocationMarker.setMap(visible ? w.map : null);
        },

        isUserLocationVisible: function () {
            if (w.userLocationMarker === null) {
                return false;
            }
            var region = w.map.getBounds();
            return (region.contains(w.userLocationMarker.getCenter()));
        },

        // Overlay Functions

        addOverlay: function (anOverlay) {
            if (w.overlays.indexOf(anOverlay) !== -1) {
                return false;
            }
            anOverlay.setMap(w.map);
            w.overlays.push(anOverlay);
            return true;
        },

        setOverlayOption: function (anOverlay, optionName, optionValue) {
            var option = {};
            option[optionName] = optionValue;
            if (anOverlay && anOverlay.setOptions) {
                anOverlay.setOptions(option);
            }
            return JSON.stringify(option);
        },

        removeOverlay: function (anOverlay) {
            if (w.overlays.indexOf(anOverlay) === -1) {
                return;
            }
            anOverlay.setMap(null);
            w.overlays.filter(function (element) {
                return element !== anOverlay;
            });
        },

        // Annotations Functions

        addAnnotation: function (anAnnotation) {
            if (w.annotations.indexOf(anAnnotation) !== -1) {
                return false;
            }

            anAnnotation.setMap(w.map);
            w.annotations.push(anAnnotation);
            if (anAnnotation.getMarker) {
                var marker = anAnnotation.getMarker();

                g.maps.event.addListener(marker, 'click', function () {
                    if (w.MKMapView) {
                        w.MKMapView.annotationScriptObjectSelected(anAnnotation);
                    }
                });
                g.maps.event.addListener(marker, 'rightclick', function () {
                    if (w.MKMapView) {
                        w.MKMapView.annotationScriptObjectRightClick(anAnnotation);
                    }
                });
                g.maps.event.addListener(marker, 'dragstart', function () {
                    if (w.MKMapView) {
                        w.MKMapView.annotationScriptObjectDragStart(anAnnotation);
                    }
                });
                g.maps.event.addListener(marker, 'drag', function () {
                    if (w.MKMapView) {
                        w.MKMapView.annotationScriptObjectDrag(anAnnotation);
                    }
                });
                g.maps.event.addListener(marker, 'dragend', function () {
                    if (w.MKMapView) {
                        w.MKMapView.annotationScriptObjectDragEnd(anAnnotation);
                    }
                });
            }
            return true;
        },

        removeAnnotation: function (anAnnotation) {
            if (w.annotations.indexOf(anAnnotation) === -1) {
                return;
            }
            anAnnotation.setMap(null);
            w.annotations.filter(function (element) {
                return element !== anAnnotation;
            });
        },

        coordinateForAnnotation: function (anAnnotation) {
            if (!anAnnotation || w.annotations.indexOf(anAnnotation) === -1) {
                return JSON.stringify({
                    "latitude": 0,
                    "longitude": 0
                });
            }

            var latlong = anAnnotation.get('position');
            return JSON.stringify({
                "latitude": latlong.lat(),
                "longitude": latlong.lng()
            });
        },

        setAnnotationCalloutHidden: function (anAnnotation, isHidden) {
            if (w.annotations.indexOf(anAnnotation) === -1) {
                return;
            }
            anAnnotation.setCalloutHidden(isHidden);
        },

        setAnnotationCalloutText: function (anAnnotation, text) {
            if (w.annotations.indexOf(anAnnotation) === -1) {
                return;
            }
            anAnnotation.setCalloutText(text);
        },

        // Converting Map Coordinates

        convertCoordinate: function (lat, lng) {
            var latlng = new g.maps.LatLng(lat, lng),
                helper = new g.maps.OverlayView(),
                mapCanvasProjection = helper.getProjection(),
                point = mapCanvasProjection.fromLatLngToContainerPixel(latlng);

            helper.setMap(w.map);
            helper.draw = function () {
                if (!this.ready) {
                    this.ready = true;
                    g.maps.event.trigger(this, 'ready');
                }
            };
            helper.setMap(null);
            return JSON.stringify({
                "x": point.x,
                "y": point.y
            });
        },

        // Javascript and CSS addons

        addJavascriptTag: function (url) {
            var scriptElement = d.createElement('script'),
                head = d.getElementsByTagName("head")[0];
            scriptElement.type = "text/javascript";
            scriptElement.src = url;
            head.appendChild(scriptElement);
        },

        addStylesheetTag: function (url) {
            var linkElement = d.createElement('link'),
                head = d.getElementsByTagName("head")[0];
            linkElement.type = "text/css";
            linkElement.href = url;
            linkElement.rel = "stylesheet";
            head.appendChild(linkElement);
            return url;
        },

        // Easy Geocoding

        showAddress: function (address) {
            var geocoder = new g.maps.Geocoder();

            geocoder.geocode({
                'address': address
            }, function (results, status) {
                if (status === g.maps.GeocoderStatus.OK) {
                    if (results[0]) {
                        var result = results[0],
                            latLng = result.geometry.location;
                        if (!latLng) {
                            return;
                        }
                        w.setCenterCoordinateAnimated(latLng.lat(), latLng.lng(), true);
                        if (w.MKMapView) {
                            w.MKMapView.webviewReportingRegionChange();
                        }
                    }
                }
            });
        },

        // Reverse Geocoding

        reverseGeocode: function (lat, lng) {
            var latlng = new g.maps.LatLng(lat, lng),
                geocoder = new g.maps.Geocoder();
            geocoder.geocode(
                {
                    'latLng': latlng
                },
                function (results, status) {
                    if (status === g.maps.GeocoderStatus.OK) {
                        if (results[0]) {
                            w.MKReverseGeocoder.didSucceedWithAddress(JSON.stringify(results[0]));
                        } else {
                            w.MKReverseGeocoder.didFailWithError("MKErrorPlacemarkNotFound");
                        }
                    } else if (status === g.maps.GeocoderStatus.ZERO_RESULTS) {
                        w.MKReverseGeocoder.didFailWithError("MKErrorPlacemarkNotFound");
                    } else if (status === g.maps.GeocoderStatus.OVER_QUERY_LIMIT) {
                        w.MKReverseGeocoder.didReachQueryLimit();
                    } else {
                        w.MKReverseGeocoder.didFailWithError("MKErrorDomain");
                    }
                }
            );
            return w.MKReverseGeocoder;
        },

        // Geocoding

        geocode: function (address, lat, lng) {
            var latlng = (lat !== null ? new g.maps.LatLng(lat, lng) : null),
                geocoder = new g.maps.Geocoder(),
                request = latlng ? {
                    'address': address,
                    'latLng': latlng
                } : {
                    'address': address
                };

            geocoder.geocode(
                request,
                function (results, status) {
                    if (status === g.maps.GeocoderStatus.OK) {
                        if (results[0]) {
                            w.MKGeocoder.didSucceedWithResult(JSON.stringify(results[0]));
                        } else {
                            w.MKGeocoder.didFailWithError("MKErrorPlacemarkNotFound");
                        }
                    } else if (status === g.maps.GeocoderStatus.ZERO_RESULTS) {
                        w.MKGeocoder.didFailWithError("MKErrorPlacemarkNotFound");
                    } else if (status === g.maps.GeocoderStatus.OVER_QUERY_LIMIT) {
                        w.MKGeocoder.didReachQueryLimit();
                    } else {
                        w.MKGeocoder.didFailWithError("MKErrorDomain");
                    }
                }
            );
            return w.MKGeocoder;
        }
    });

    //
    // Initialize
    //
    (function () {
        var latlng, myOptions, regionChangeFunction, clickFunction, mapView;

        w.map = null;
        w.userLocationMarker = null;
        w.overlays = [];
        w.annotations = [];

        try {
            latlng = new g.maps.LatLng(49.85770356304121, -97.1528089768459);
            myOptions = {
                zoom: 13,
                center: latlng,
                disableDefaultUI: true,
                navigationControl: false,
                scrollwheel: false,
                navigationControlOptions: {
                    style: g.maps.NavigationControlStyle.SMALL,
                    position: g.maps.ControlPosition.TOP_LEFT
                },
                scaleControl: false,
                mapTypeId: g.maps.MapTypeId.ROADMAP
            };
            w.map = new g.maps.Map(d.getElementById("map_canvas"), myOptions);

            regionChangeFunction = function () {
                if (w.MKMapView) {
                    w.MKMapView.webviewReportingRegionChange();
                }
            };

            clickFunction = function (mouseEvent) {
                if (w.MKMapView) {
                    var jsonLatLong = JSON.stringify({
                        "latitude": mouseEvent.latLng.lat(),
                        "longitude": mouseEvent.latLng.lng()
                    });
                    w.MKMapView.webviewReportingClick(jsonLatLong);
                }
            };

            g.maps.event.addListener(w.map, 'drag', regionChangeFunction);
            g.maps.event.addListener(w.map, 'zoom_changed', regionChangeFunction);
            g.maps.event.addListener(w.map, 'click', clickFunction);

            w.createUserLocationMarker();
        } catch (err) {
            if (w.MKMapView) {
                w.MKMapView.webviewReportingLoadFailure();
            }
        }

        if (w.map === null) {
            mapView = d.getElementById("map_canvas");
            mapView.innerHTML = "<div class='mapKitLoadError'><div class='mapKitLoadErrorCenter'><div class='mapKitLoadErrorMessage'>Error Loading MapView, an internet connection is required. <br/><button onclick='w.MKMapView.webviewReportingReloadGmaps()'>Retry</button></div></div></div>";
        }
    }());

}(window, document, window.google));