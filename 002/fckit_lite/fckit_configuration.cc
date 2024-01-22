/*
 * (C) Copyright 2013 ECMWF.
 *
 * This software is licensed under the terms of the Apache Licence Version 2.0
 * which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
 * In applying this licence, ECMWF does not waive the privileges and immunities
 * granted to it by virtue of its status as an intergovernmental organisation
 * nor does it submit to any jurisdiction.
 */

#include <cstdio>
#include <cstdarg>
#include <cstdint>
#include <cstring>
#include <iostream>
#include <stdexcept>


using int32  = std::int32_t;
using int64  = std::int64_t;
using size_t = std::size_t;

namespace fckit {

extern "C" {

static int fckit_configurations_alive_ = 0;

extern "C" {
int fckit_configurations_alive() {
    return fckit_configurations_alive_;
}
}

struct Configuration {
    Configuration() {
        fckit_configurations_alive_++;
        std::cerr << "     fckit_configuration.cc @ " << __LINE__ << " : Constructed fckit_configuration, now allocated: " << fckit_configurations_alive_ << std::endl;
    }
    ~Configuration() {
        fckit_configurations_alive_--;
        std::cerr << "     fckit_configuration.cc @ " << __LINE__ << " : Deleted fckit_configuration, now allocated: " << fckit_configurations_alive_ << std::endl;
    }
    char key[8];
    int value;
};

Configuration* c_fckit_configuration_new() {
    return new Configuration();
}

void c_fckit_configuration_delete( Configuration* This ) {
    delete This;
}

void c_fckit_configuration_get_config_list( const Configuration* This, int size, Configuration**& value ) {
    value = new Configuration*[size];
    for ( int i = 0; i < size; ++i ) {
        value[i] = new Configuration();
        snprintf(value[i]->key, 8, "x");
        value[i]->value=i+1;
    }
}

void c_fckit_configuration_json( const Configuration* This, char*& json, size_t& size ) {
    char buffer[32];
    size = snprintf(buffer, sizeof(buffer), "{\"%s\",%d}", This->key, This->value);
    buffer[size] = '\0';
    json            = new char[size + 1];
    strcpy( json, buffer );
}

}  // extern "C"

}  // namespace fckit
