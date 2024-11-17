/*
 * Copyright (c) 2024 CodeFusionBit. All rights reserved.
 * Author: Hitesh Sapra
 *
 * This software is the confidential and proprietary information of CodeFusionBit.
 * You shall not disclose such confidential information and shall use it only in
 * accordance with the terms of the license agreement you entered into with
 * CodeFusionBit.
 *
 * Website: https://codefusionbit.com
 * Contact: info@codefusionbit.com
 */

/// A span of text that should be highlighted in a specific way.
class HighlightSpan {
  final String type;
  final int start;
  final int end;

  HighlightSpan({
    required this.type,
    required this.start,
    required this.end,
  });
}
