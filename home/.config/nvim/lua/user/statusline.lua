local galaxyline = require('galaxyline')
local section = galaxyline.section

-- Colors
local colors = {
  bg = '#282828',
  fg = '#ebdbb2',
  section_bg = '#3c3836',
  yellow = '#d79921',
  cyan = '#83a598',
  green = '#98971a',
  orange = '#fe8019',
  magenta = '#b16286',
  blue = '#689d6a',
  red = '#cc241d'
}

-- Local helper functions
local is_buffer_empty = function()
  return vim.fn.empty(vim.fn.expand('%:t')) == 1
end

local buffer_not_empty = function()
  return not is_buffer_empty()
end

local has_width_gt = function(cols)
  return vim.fn.winwidth(0) / 2 > cols
end

local checkwidth = function()
  return has_width_gt(40) and buffer_not_empty()
end

local mode_color = function()
  local mode_colors = {
    n = colors.cyan,
    i = colors.green,
    c = colors.orange,
    V = colors.magenta,
    [''] = colors.magenta,
    v = colors.magenta,
    R = colors.red,
  }

  return mode_colors[vim.fn.mode()]
end

-- Left side
section.left[1] = {
  BeginSpacer = {
    provider = function() return '  ' end,
    highlight = { colors.bg, colors.bg}
  },
}
section.left[2] = {
  ViMode = {
    provider = function()
      local alias = {
        n = 'NORMAL',
        i = 'INSERT',
        c = 'COMMAND',
        V = 'VISUAL',
        [''] = 'VISUAL',
        v = 'VISUAL',
        R = 'REPLACE',
      }
      vim.api.nvim_command('hi GalaxyViMode guifg='..mode_color())
      return alias[vim.fn.mode()]..' '
    end,
    highlight = { colors.bg, colors.bg },
    separator = " ",
    separator_highlight = {colors.bg, colors.section_bg},
  },
}
section.left[3] ={
  FileIcon = {
    provider = 'FileIcon',
    condition = buffer_not_empty,
    highlight = { require('galaxyline.provider_fileinfo').get_file_icon_color, colors.section_bg },
  },
}
section.left[4] = {
  FileName = {
    provider = { 'FileName', 'FileSize' },
    condition = buffer_not_empty,
    highlight = { colors.fg, colors.section_bg },
    separator = " ",
    separator_highlight = {colors.section_bg, colors.bg},
  }
}
section.left[5] = {
  GitIcon = {
    provider = function() return ' ' end,
    condition = buffer_not_empty,
    highlight = {colors.red,colors.bg},
  }
}
section.left[6] = {
  GitBranch = {
    provider = 'GitBranch',
    condition = buffer_not_empty,
    highlight = {colors.fg,colors.bg},
  }
}
section.left[7] = {
  DiffAdd = {
    provider = 'DiffAdd',
    condition = checkwidth,
    icon = ' ',
    highlight = { colors.green, colors.bg },
  }
}
section.left[8] = {
  DiffModified = {
    provider = 'DiffModified',
    condition = checkwidth,
    icon = ' ',
    highlight = { colors.orange, colors.bg },
  }
}
section.left[9] = {
  DiffRemove = {
    provider = 'DiffRemove',
    condition = checkwidth,
    icon = ' ',
    highlight = { colors.red,colors.bg },
  }
}
section.left[10] = {
  LeftEnd = {
    provider = function() return ' '  end,
    condition = buffer_not_empty,
    highlight = {colors.bg,colors.section_bg}
  }
}
section.left[11] = {
  DiagnosticError = {
    provider = 'DiagnosticError',
    icon = '  ',
    highlight = {colors.red,colors.section_bg}
  }
}
section.left[12] = {
  Space = {
    provider = function () return ' ' end,
    highlight = {colors.section_bg,colors.section_bg},
  }
}
section.left[13] = {
  DiagnosticWarn = {
    provider = 'DiagnosticWarn',
    icon = '  ',
    highlight = {colors.orange,colors.section_bg},
  }
}
section.left[14] = {
  Space = {
    provider = function () return ' ' end,
    highlight = {colors.section_bg,colors.section_bg},
  }
}
section.left[15] = {
  DiagnosticInfo = {
    provider = 'DiagnosticInfo',
    icon = '  ',
    highlight = {colors.blue,colors.section_bg},
    separator = ' ',
    separator_highlight = { colors.section_bg, colors.bg },
  }
}

-- Right side
section.right[1] = {
  BeginSlope = {
    provider = function () return '' end,
    highlight = {colors.section_bg,colors.bg},
  }
}
section.right[2]= {
  FileFormat = {
    provider = function() return vim.bo.filetype end,
    highlight = { colors.fg,colors.section_bg },
    separator = ' ',
    separator_highlight = { colors.section_bg,colors.section_bg },
  }
}
section.right[3] = {
  LineInfo = {
    provider = 'LineColumn',
    highlight = { colors.fg, colors.section_bg },
    separator = ' | ',
    separator_highlight = { colors.bg, colors.section_bg },
  },
}
section.right[4] = {
  EndSpacer = {
    provider = function () return '  ' end,
    highlight = {colors.section_bg,colors.section_bg},
  }
}

-- Short status line
section.short_line_left[1] = {
  BufferType = {
    provider = 'FileTypeName',
    highlight = { colors.fg, colors.section_bg },
    separator = ' ',
    separator_highlight = { colors.section_bg, colors.bg },
  }
}

section.short_line_right[1] = {
  BufferIcon = {
    provider= 'BufferIcon',
    highlight = { colors.yellow, colors.section_bg },
    separator = ' ',
    separator_highlight = { colors.section_bg, colors.bg },
  }
}

-- Force manual load so that nvim boots with a status line
galaxyline.load_galaxyline()
