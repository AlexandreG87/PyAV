cimport libav as lib

from av.format cimport ContainerFormat
from av.stream cimport Stream

# Since there are multiple objects that need to refer to a valid context, we
# need this intermediate proxy object so that there aren't any reference cycles
# and the pointer can be freed when everything that depends upon it is deleted.
cdef class Container(object):

    cdef bint writeable
    cdef lib.AVFormatContext *ptr

    cdef _seek(self, int stream_index, lib.int64_t timestamp, str mode, bint backward, bint any_frame)
    cdef flush_buffers(self)

    cdef readonly str name

    # File-like source.
    cdef readonly object file
    cdef object fread
    cdef object fwrite
    cdef object fseek
    cdef object ftell

    # Custom IO for above.
    cdef lib.AVIOContext *iocontext
    cdef long bufsize
    cdef unsigned char *buffer
    cdef long pos
    cdef bint pos_is_valid
    
    # Thread-local storage for exceptions.
    cdef object local
    cdef int err_check(self, int value) except -1

    cdef readonly ContainerFormat format
    cdef lib.AVDictionary *options

    cdef void* streams_ptr
    cdef readonly dict metadata


cdef class InputContainer(Container):
    pass


cdef class OutputContainer(Container):

    cdef bint _started
    cdef bint _done

    cpdef add_stream(self, codec_name=*, object rate=*, Stream template=*)
    cpdef start_encoding(self)
