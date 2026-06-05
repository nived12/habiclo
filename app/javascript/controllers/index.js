import { application } from "./application"

import AgendaBlockController from "./agenda_block_controller"
import BrandHueController from "./brand_hue_controller"
import KeyboardNavController from "./keyboard_nav_controller"
import InlineEditorController from "./inline_editor_controller"
import HelpController from "./help_controller"
import ModalController from "./modal_controller"
import FrequencyFieldsController from "./frequency_fields_controller"
import RingSegmentController from "./ring_segment_controller"
import LegendToggleController from "./legend_toggle_controller"
import WeeklyCellController from "./weekly_cell_controller"
import ResourceDestroyController from "./resource_destroy_controller"
import CollapseController from "./collapse_controller"
import SwatchPickerController from "./swatch_picker_controller"
import TzDetectController from "./tz_detect_controller"
import FlashController from "./flash_controller"

application.register("agenda-block", AgendaBlockController)
application.register("brand-hue", BrandHueController)
application.register("keyboard-nav", KeyboardNavController)
application.register("inline-editor", InlineEditorController)
application.register("help", HelpController)
application.register("modal", ModalController)
application.register("frequency-fields", FrequencyFieldsController)
application.register("ring-segment", RingSegmentController)
application.register("legend-toggle", LegendToggleController)
application.register("weekly-cell", WeeklyCellController)
application.register("resource-destroy", ResourceDestroyController)
application.register("collapse", CollapseController)
application.register("swatch-picker", SwatchPickerController)
application.register("tz-detect", TzDetectController)
application.register("flash", FlashController)
