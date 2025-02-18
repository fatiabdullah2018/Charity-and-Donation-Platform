import { describe, it, expect } from "vitest"

// Mock the Clarity functions and types
const mockClarity = {
  tx: {
    sender: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM",
  },
  types: {
    uint: (value: number) => ({ type: "uint", value }),
    principal: (value: string) => ({ type: "principal", value }),
  },
}

// Mock contract calls
const contractCalls = {
  donate: (campaignId: number, amount: number) => {
    return { success: true, value: mockClarity.types.uint(amount) }
  },
  "get-donation": (donationId: number) => {
    return {
      success: true,
      value: {
        donor: mockClarity.types.principal("ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM"),
        "campaign-id": mockClarity.types.uint(0),
        amount: mockClarity.types.uint(100000),
        timestamp: mockClarity.types.uint(123456),
      },
    }
  },
}

describe("Donation Contract", () => {
  it("should make a donation", () => {
    const result = contractCalls.donate(0, 100000)
    expect(result.success).toBe(true)
    expect(result.value).toEqual(mockClarity.types.uint(100000))
  })
  
  it("should get donation details", () => {
    const result = contractCalls["get-donation"](0)
    expect(result.success).toBe(true)
    expect(result.value).toEqual({
      donor: mockClarity.types.principal("ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM"),
      "campaign-id": mockClarity.types.uint(0),
      amount: mockClarity.types.uint(100000),
      timestamp: mockClarity.types.uint(123456),
    })
  })
})

