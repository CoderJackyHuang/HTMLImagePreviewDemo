//
//  ViewController.swift
//  HTMLImagePreviewSwift
//
//  Created by huangyibiao on 16/2/1.
//  Copyright © 2016年 huangyibiao. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate {
  var webView = UIWebView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.addSubview(self.webView)
    self.webView.delegate = self
    self.webView.frame = self.view.bounds
    self.webView.loadRequest(NSURLRequest(URL: NSURL(string: "http://www.cocoachina.com/programmer/20160113/14976.html")!))
  }
  
  
  // MARK: UIWebViewDelegate
  func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    let scheme = "hyb-image-preview:"
    // 由于我们注入了JS，在点击HTML中的图片时，就会跳转，然后在此处就可以拦截到
    if ((request.URL?.scheme.hasPrefix(scheme)) != nil) {
      // 获取原始图片的URL
      let src = request.URL?.absoluteString.stringByReplacingOccurrencesOfString(scheme, withString: "")
      if let imageUrl = src {
        // 原生API展开图片
        // 这里已经拿到所点击的图片的URL了，剩下的部分，自己处理了
        // 有时候会感觉点击无响应，这是因为webViewDidFinishLoad,还没有调用。
        // 调用很晚的原因，通常是因为H5页面中有比较多的内容在加载
        // 因此，若是原生APP与H5要交互，H5要尽可能地提高加载速度
        // 不相信？在webViewDidFinishLoad加个断点就知道了
        print(imageUrl)
      }
    }
    
    return true
  }
  
  func webViewDidFinishLoad(webView: UIWebView) {
    // 在H5页面加载完成时，注入图片点击的JS代码
    let js = "function addImgClickEvent() { " +
      "var imgs = document.getElementsByTagName('img');" +
      // 遍历所有的img标签，统一加上点击事件
      "for (var i = 0; i < imgs.length; ++i) {" +
      "var img = imgs[i];" +
      "img.onclick = function () {" +
      // 给图片添加URL scheme，以便在拦截时可能识别跳转
      "window.location.href = 'hyb-image-preview:' + this.src;" +
      "}" +
      "}" +
    "}"
    // 注入JS代码
    self.webView.stringByEvaluatingJavaScriptFromString(js)
    
    // 执行所注入的JS
    self.webView.stringByEvaluatingJavaScriptFromString("addImgClickEvent();")
  }
}

