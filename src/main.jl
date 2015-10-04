using Modbus
using AnimatedPlots

const IP_ADDR = "127.0.0.1"
const PORT = 502
const UNIT_ID = 1
const REF_ADDR = 0
const NUM_REGS = 2
const TIMEOUT_SEC = 0
const TIMEOUT_USEC = 750000

function connect()
    ctx = modbus_new_tcp(IP_ADDR, PORT)
    modbus_set_slave(ctx, UNIT_ID)
    modbus_set_response_timeout(ctx, TIMEOUT_SEC, TIMEOUT_USEC)
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

function main()
    ctx = connect()

    animated_plot = AnimatedGraph(x -> get_register_values(ctx)[1])
    animated_plot.speed = 10
    plot(animated_plot)
    follow(animated_plot)
    #disconnect(ctx)
end

main()
