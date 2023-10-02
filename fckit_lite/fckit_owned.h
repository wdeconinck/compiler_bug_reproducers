/*
 * (C) Copyright 2013 ECMWF.
 *
 * This software is licensed under the terms of the Apache Licence Version 2.0
 * which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
 * In applying this licence, ECMWF does not waive the privileges and immunities
 * granted to it by virtue of its status as an intergovernmental organisation
 * nor does it submit to any jurisdiction.
 */

#pragma once
#include <cstdint>
#include <cstddef>

namespace eckit {
class Owned {

public:  // methods
    Owned() :
        count_(0) {}

    Owned(const Owned&)            = delete;
    Owned& operator=(const Owned&) = delete;

    virtual ~Owned() {}

    void attach() const {
        count_++;
    }

    void detach() const {
        --count_;
    }

    std::size_t owners() const { return count_; }

private:  // members
    mutable std::size_t count_;
};
}

