#program_export __ubsan_handle_pointer_overflow :: () #c_call {
    push_context {
        assert(false, "pointer overflow");
    }
}
#program_export __ubsan_handle_sub_overflow :: () #c_call {
    push_context {
        assert(false, "sub overflow");
    }
}
#program_export __ubsan_handle_shift_out_of_bounds :: () #c_call {
    push_context {
        assert(false, "shift out of bounds");
    }
}
#program_export __ubsan_handle_divrem_overflow :: () #c_call {
    push_context {
        assert(false, "divrem overflow");
    }
}
#program_export __ubsan_handle_out_of_bounds :: () #c_call {
    push_context {
        assert(false, "out of bounds");
    }
}
#program_export __ubsan_handle_add_overflow :: () #c_call {
    push_context {
        assert(false, "add overflow");
    }
}
#program_export __ubsan_handle_mul_overflow :: () #c_call {
    push_context {
        assert(false, "mul overflow");
    }
}
#program_export __ubsan_handle_load_invalid_value :: () #c_call {
    push_context {
        assert(false, "invalid value");
    }
}
#program_export __ubsan_handle_type_mismatch_v1 :: () #c_call {
    push_context {
        assert(false, "type mismatch");
    }
}
#program_export __ubsan_handle_builtin_unreachable :: () #c_call {
    push_context {
        assert(false, "unreachable");
    }
}

