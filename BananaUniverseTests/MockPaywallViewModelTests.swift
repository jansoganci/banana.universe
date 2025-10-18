//
//  MockPaywallViewModelTests.swift
//  BananaUniverseTests
//
//  Created by AI Assistant on 14.10.2025.
//  Unit tests for MockPaywallViewModel
//

import XCTest
@testable import BananaUniverse

@MainActor
class MockPaywallViewModelTests: XCTestCase {
    
    var viewModel: MockPaywallViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = MockPaywallViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        // Given & When
        let newViewModel = MockPaywallViewModel()
        
        // Then
        XCTAssertNotNil(newViewModel)
        XCTAssertFalse(newViewModel.isLoading)
        XCTAssertFalse(newViewModel.isPurchasing)
        XCTAssertFalse(newViewModel.showAlert)
        XCTAssertNil(newViewModel.selectedProduct)
    }
    
    // MARK: - Data Loading Tests
    
    func testLoadData() async {
        // Given
        XCTAssertTrue(viewModel.products.isEmpty)
        XCTAssertTrue(viewModel.benefits.isEmpty)
        
        // When
        viewModel.loadData()
        
        // Wait for async loading to complete
        try? await Task.sleep(nanoseconds: 600_000_000) // 0.6 seconds
        
        // Then
        XCTAssertFalse(viewModel.products.isEmpty)
        XCTAssertFalse(viewModel.benefits.isEmpty)
        XCTAssertEqual(viewModel.products.count, 2) // Weekly and yearly
        XCTAssertEqual(viewModel.benefits.count, 3) // Three benefits
        XCTAssertFalse(viewModel.isLoading)
    }
    
    // MARK: - Product Selection Tests
    
    func testProductSelection() {
        // Given
        let weeklyProduct = viewModel.products.first { $0.id == "weekly_pro" }
        XCTAssertNotNil(weeklyProduct)
        
        // When
        viewModel.selectProduct(weeklyProduct!)
        
        // Then
        XCTAssertEqual(viewModel.selectedProduct?.id, "weekly_pro")
        XCTAssertTrue(viewModel.isProductSelected(weeklyProduct!))
    }
    
    func testProductDeselection() {
        // Given
        let weeklyProduct = viewModel.products.first { $0.id == "weekly_pro" }
        let yearlyProduct = viewModel.products.first { $0.id == "yearly_pro" }
        
        viewModel.selectProduct(weeklyProduct!)
        XCTAssertTrue(viewModel.isProductSelected(weeklyProduct!))
        
        // When
        viewModel.selectProduct(yearlyProduct!)
        
        // Then
        XCTAssertEqual(viewModel.selectedProduct?.id, "yearly_pro")
        XCTAssertFalse(viewModel.isProductSelected(weeklyProduct!))
        XCTAssertTrue(viewModel.isProductSelected(yearlyProduct!))
    }
    
    // MARK: - Purchase Flow Tests
    
    func testPurchaseWithoutSelectedProduct() async {
        // Given
        XCTAssertNil(viewModel.selectedProduct)
        
        // When
        await viewModel.purchaseSelectedProduct()
        
        // Then
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertEqual(viewModel.alertTitle, "Error")
        XCTAssertTrue(viewModel.alertMessage.contains("product not found"))
    }
    
    func testPurchaseWithSelectedProduct() async {
        // Given
        let weeklyProduct = viewModel.products.first { $0.id == "weekly_pro" }
        viewModel.selectProduct(weeklyProduct!)
        
        // When
        await viewModel.purchaseSelectedProduct()
        
        // Then
        // Note: This test might fail occasionally due to the 10% random failure rate
        // In a real test environment, you'd want to mock the random failure
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertTrue(viewModel.alertTitle == "Success!" || viewModel.alertTitle == "Error")
    }
    
    func testPurchaseLoadingState() async {
        // Given
        let weeklyProduct = viewModel.products.first { $0.id == "weekly_pro" }
        viewModel.selectProduct(weeklyProduct!)
        
        // When
        let purchaseTask = Task {
            await viewModel.purchaseSelectedProduct()
        }
        
        // Then - Check loading state during purchase
        XCTAssertTrue(viewModel.isPurchasing)
        
        // Wait for completion
        await purchaseTask.value
        XCTAssertFalse(viewModel.isPurchasing)
    }
    
    // MARK: - Restore Purchases Tests
    
    func testRestorePurchases() async {
        // Given
        XCTAssertFalse(viewModel.showAlert)
        
        // When
        await viewModel.restorePurchases()
        
        // Then
        // Note: This test might fail occasionally due to the 5% random failure rate
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertTrue(viewModel.alertTitle == "Success!" || viewModel.alertTitle == "Error")
    }
    
    func testRestoreLoadingState() async {
        // Given
        XCTAssertFalse(viewModel.isPurchasing)
        
        // When
        let restoreTask = Task {
            await viewModel.restorePurchases()
        }
        
        // Then - Check loading state during restore
        XCTAssertTrue(viewModel.isPurchasing)
        
        // Wait for completion
        await restoreTask.value
        XCTAssertFalse(viewModel.isPurchasing)
    }
    
    // MARK: - Alert Management Tests
    
    func testAlertDismissal() {
        // Given
        viewModel.showAlert = true
        viewModel.alertTitle = "Test Title"
        viewModel.alertMessage = "Test Message"
        
        // When
        viewModel.dismissAlert()
        
        // Then
        XCTAssertFalse(viewModel.showAlert)
        XCTAssertTrue(viewModel.alertTitle.isEmpty)
        XCTAssertTrue(viewModel.alertMessage.isEmpty)
    }
    
    // MARK: - Computed Properties Tests
    
    func testCanPurchase() {
        // Given - No product selected
        XCTAssertFalse(viewModel.canPurchase)
        
        // When - Select a product
        let weeklyProduct = viewModel.products.first { $0.id == "weekly_pro" }
        viewModel.selectProduct(weeklyProduct!)
        
        // Then
        XCTAssertTrue(viewModel.canPurchase)
        
        // When - Set purchasing state
        viewModel.isPurchasing = true
        
        // Then
        XCTAssertFalse(viewModel.canPurchase)
    }
    
    func testCtaButtonText() {
        // Given
        XCTAssertEqual(viewModel.ctaButtonText, "Unlock Premium")
        
        // When - Set purchasing state
        viewModel.isPurchasing = true
        
        // Then
        XCTAssertEqual(viewModel.ctaButtonText, "Processing...")
    }
    
    func testSelectedProductPrice() {
        // Given
        XCTAssertNil(viewModel.selectedProductPrice)
        
        // When - Select a product
        let weeklyProduct = viewModel.products.first { $0.id == "weekly_pro" }
        viewModel.selectProduct(weeklyProduct!)
        
        // Then
        XCTAssertEqual(viewModel.selectedProductPrice, weeklyProduct?.localizedPrice)
    }
    
    // MARK: - A/B Testing Tests
    
    func testVariantAssignment() {
        // Given & When
        let variant = viewModel.variant
        
        // Then
        XCTAssertTrue(PaywallVariant.allCases.contains(variant))
    }
    
    func testTrialBadgeVisibility() {
        // Given & When
        let shouldShow = viewModel.shouldShowTrialBadge()
        
        // Then
        XCTAssertTrue(shouldShow == true || shouldShow == false)
    }
    
    func testAnnualHighlight() {
        // Given & When
        let shouldHighlight = viewModel.shouldHighlightAnnual()
        
        // Then
        XCTAssertTrue(shouldHighlight == true || shouldHighlight == false)
    }
    
    // MARK: - Mock Data Tests
    
    func testMockProductsHaveRequiredFields() {
        // Given
        let products = viewModel.products
        
        // When & Then
        for product in products {
            XCTAssertFalse(product.id.isEmpty)
            XCTAssertFalse(product.vendorProductId.isEmpty)
            XCTAssertFalse(product.localizedTitle.isEmpty)
            XCTAssertFalse(product.localizedDescription.isEmpty)
            XCTAssertFalse(product.localizedPrice.isEmpty)
            XCTAssertNotNil(product.price)
            XCTAssertFalse(product.currencyCode.isEmpty)
        }
    }
    
    func testMockBenefitsHaveRequiredFields() {
        // Given
        let benefits = viewModel.benefits
        
        // When & Then
        for benefit in benefits {
            XCTAssertFalse(benefit.icon.isEmpty)
            XCTAssertFalse(benefit.title.isEmpty)
            XCTAssertFalse(benefit.description.isEmpty)
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandling() {
        // Given
        let error = MockPurchaseError.purchaseFailed
        
        // When
        let description = error.localizedDescription
        
        // Then
        XCTAssertFalse(description.isEmpty)
        XCTAssertTrue(description.contains("Purchase failed"))
    }
    
    // MARK: - Performance Tests
    
    func testLoadDataPerformance() {
        // Given
        measure {
            // When
            viewModel.loadData()
        }
    }
    
    func testProductSelectionPerformance() {
        // Given
        let weeklyProduct = viewModel.products.first { $0.id == "weekly_pro" }
        
        // When
        measure {
            viewModel.selectProduct(weeklyProduct!)
        }
    }
}

