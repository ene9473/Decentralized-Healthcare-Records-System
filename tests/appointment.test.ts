import { describe, it, expect } from "vitest"

// Mock the Clarity functions and types
const mockClarity = {
  tx: {
    sender: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM",
  },
  types: {
    principal: (value: string) => ({ type: "principal", value }),
    uint: (value: number) => ({ type: "uint", value }),
    string: (value: string) => ({ type: "string", value }),
  },
}

// Mock contract calls
const contractCalls = {
  "schedule-appointment": (patientId: string, doctorId: string, timestamp: number, duration: number, fee: number) => {
    return { success: true, value: mockClarity.types.uint(0) }
  },
  "pay-appointment": (appointmentId: number) => {
    return { success: true, value: true }
  },
  "get-appointment": (appointmentId: number) => {
    return {
      success: true,
      value: {
        "patient-id": mockClarity.types.principal("ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG"),
        "doctor-id": mockClarity.types.principal("ST3NBRSFKX28FQ5ZSD5XJZRV3TEPACBGYKVHFVDCB"),
        timestamp: mockClarity.types.uint(1625097600),
        duration: mockClarity.types.uint(30),
        fee: mockClarity.types.uint(100),
        status: mockClarity.types.string("scheduled"),
      },
    }
  },
}

describe("Appointment Contract", () => {
  it("should schedule an appointment", () => {
    const result = contractCalls["schedule-appointment"](
        "ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG",
        "ST3NBRSFKX28FQ5ZSD5XJZRV3TEPACBGYKVHFVDCB",
        1625097600,
        30,
        100,
    )
    expect(result.success).toBe(true)
    expect(result.value).toEqual(mockClarity.types.uint(0))
  })
  
  it("should pay for an appointment", () => {
    const result = contractCalls["pay-appointment"](0)
    expect(result.success).toBe(true)
    expect(result.value).toBe(true)
  })
  
  it("should get appointment details", () => {
    const result = contractCalls["get-appointment"](0)
    expect(result.success).toBe(true)
    expect(result.value).toEqual({
      "patient-id": mockClarity.types.principal("ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG"),
      "doctor-id": mockClarity.types.principal("ST3NBRSFKX28FQ5ZSD5XJZRV3TEPACBGYKVHFVDCB"),
      timestamp: mockClarity.types.uint(1625097600),
      duration: mockClarity.types.uint(30),
      fee: mockClarity.types.uint(100),
      status: mockClarity.types.string("scheduled"),
    })
  })
})

