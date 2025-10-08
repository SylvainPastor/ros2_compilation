COLCON_OUTPUT = --event-handlers console_direct+
#BUILD_TYPE    = "-DCMAKE_BUILD_TYPE=Debug"
#BUILD_OPTIONS = "-DBUILD_EXE:BOOL=ON -DBUILD_TESTING:BOOL=ON"

.DEFAULT: all
all: build_ws

# Build ROS workspace
# --------------------------------------------------------------------
build_ws:
	@colcon build --symlink-install \
		--cmake-args \
		$(BUILD_TYPE) \
		$(CMAKE_OPTIONS) \
		$(COLCON_OUTPUT)

# Clean workspace
# --------------------------------------------------------------------
.PHONY: clean
clean:
	@rm -rf build install log
	
# Clean source
# --------------------------------------------------------------------
.PHONY: clean_source
clean_source:
	@rm -rf src
