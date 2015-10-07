using Modbus
using Gadfly, Interact
using Reactive

const IP_ADDR = "127.0.0.1"
const PORT = 502
const UNIT_ID = 1
const REF_ADDR = 0
const NUM_REGS = 2
const TIMEOUT_SEC = 0
const TIMEOUT_USEC = 750000
const SLEEP_TIME = 0.25

function connect()
    ctx = modbus_new_tcp(IP_ADDR, PORT)
    modbus_set_slave(ctx, UNIT_ID)
    #modbus_set_response_timeout(ctx, TIMEOUT_SEC, TIMEOUT_USEC)
    modbus_connect(ctx)
    return ctx
end

function get_register_values(ctx)
    dest = modbus_read_registers(ctx, REF_ADDR, NUM_REGS)
    floatregs = modbus_convert_regs(dest, Float32)
    return floatregs
end

function disconnect(ctx)
    modbus_close(ctx)
    modbus_free(ctx)
end

function next_arr!(ctx, arr)
    arr[1:end-1] = arr[2:end]
    arr[end] = get_register_values(ctx)[1]
    arr
end

function main(window)
    ctx = connect()
    arr = zeros(Float32, 100)
    arr_sig = lift(_ -> next_arr!(ctx, arr), fpswhen(window.alive, 30))

    lift(y -> plot(x=collect(1:100), y=y, Geom.line), arr_sig)
end
