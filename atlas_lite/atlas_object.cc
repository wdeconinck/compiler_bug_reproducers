#include <stdio.h>
#include <iostream>
#include <sstream>
#include <string>
#include <map>

#include "fckit_owned.h"

#define __FILENAME__ "atlas_object.cc"

extern "C" {
void fckit_write_to_fortran_unit( int unit, const char* msg );
int fckit_fortranunit_stdout();
int fckit_fortranunit_stderr();
}

std::map<int,int> object_destroyed;

class Object : eckit::Owned {
public:
    Object( int i ) : eckit::Owned(), i_( i ) {
        std::stringstream out;
        out << __FILENAME__ << " @ " << __LINE__ <<  " :  " << "constructing Object " << i_;
        fckit_write_to_fortran_unit( fckit_fortranunit_stderr(), out.str().c_str() );

        // Log this for testing purpose
        object_destroyed[i_] = 0;
    }
    ~Object() {
        std::stringstream out;
        out << __FILENAME__ << " @ " << __LINE__ <<  " :  " << "destructing Object " << i_;
        fckit_write_to_fortran_unit( fckit_fortranunit_stderr(), out.str().c_str() );
        if (other_) {
            other_->detach();
            if( other_->owners() == 0 ) {
                delete other_;
            }
        }
        object_destroyed[i_] = 1;
    }
    int id() const { return i_; }

    void set_other(Object* other) {
        if (other_) {
            other_->detach();
            if( other_->owners() == 0 ) {
                delete other_;
            }
        }
        other_ = other;
        other_->attach();
        std::stringstream out;
        out << __FILENAME__ << " @ " << __LINE__ <<  " :  " << "Object " << id() << " setting other [id = " << other_->id() << ", owners = " << other_->owners() << "]";
        fckit_write_to_fortran_unit( fckit_fortranunit_stderr(), out.str().c_str() );
    }

    Object* other() const {
        return other_;
    }

private:
    int i_;
    Object* other_{nullptr};
};

extern "C" {
Object* new_Object( int i ) {
    return new Object( i );
}
void delete_Object( Object* p ) {
    delete p;
}
int Object__id( const Object* p ) {
    return p->id();
}
void Object__set_other( Object* p, Object* o ) {
    p->set_other(o);
}
Object* Object__other( Object* p) {
    return p->other();
}

int Object__destroyed(int i) {
    return object_destroyed.at(i);
}


}
